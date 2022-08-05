defmodule NarwinChat.Store do
  use GenServer

  def start_link(opts \\ [name: __MODULE__]) do
    GenServer.start_link(__MODULE__, nil, opts)
  end

  @impl true
  def init(_) do
    {:ok, %{messages: [], users: []}}
  end

  @impl true
  def handle_call({:join, user_params}, _from, %{users: users} = state) do
    user =
      user_params
      |> Map.put_new(:id, Ecto.UUID.generate())

    refresh_users_deferred()

    {:reply, state, %{state | users: users ++ [user]}}
  end

  @impl true
  def handle_call({:leave, pid}, _from, %{users: users} = state) do
    refresh_users_deferred()

    {:reply, :ok, %{state | users: Enum.filter(users, &(&1.pid != pid))}}
  end

  @impl true
  def handle_call(
        {:message, %{message: message_text, pid: pid}},
        _from,
        %{messages: messages, users: users} = state
      ) do
    user = Enum.find(users, &(&1.pid == pid))

    message = %{
      id: Ecto.UUID.generate(),
      text: message_text,
      user: user
    }

    refresh_users_deferred()

    {:reply, :ok, %{state | messages: messages ++ [message]}}
  end

  @impl true
  def handle_info(:refresh_users, %{users: users} = state) do
    for %{pid: pid} <- users do
      send(pid, {:refresh_state, state})
    end

    {:noreply, state}
  end

  ###

  defp refresh_users_deferred do
    Process.send_after(self(), :refresh_users, 10)
  end
end
