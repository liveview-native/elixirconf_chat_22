defmodule NarwinChat.Dispatcher do
  use GenServer
  require Logger
  import Ecto.Query

  alias NarwinChat.Repo
  alias NarwinChat.Accounts.User
  alias NarwinChat.Chat.{Room, Message}

  def start_link(opts \\ [name: __MODULE__]) do
    GenServer.start_link(__MODULE__, nil, opts)
  end

  @spec join_lobby(integer()) :: %{integer() => integer()}
  def join_lobby(user_id) do
    GenServer.call(__MODULE__, {:join_lobby, user_id})
  end

  @spec leave_lobby() :: :ok
  def leave_lobby() do
    GenServer.cast(__MODULE__, {:leave_lobby, self()})
  end

  @spec join(integer(), integer()) :: [Message.t()]
  def join(room_id, user_id) do
    GenServer.call(__MODULE__, {:join, room_id, user_id})
  end

  @spec leave(integer()) :: :ok
  def leave(room_id) do
    GenServer.cast(__MODULE__, {:leave, room_id, self()})
  end

  @spec post(integer(), integer(), String.t()) :: :ok
  def post(user_id, room_id, body) do
    GenServer.cast(__MODULE__, {:post, user_id, room_id, body})
  end

  @spec get_users(integer()) :: [User.t()]
  def get_users(room_id) do
    user_ids = GenServer.call(__MODULE__, {:get_users, room_id})

    Repo.all(
      from u in User,
        where: u.id in ^user_ids,
        where: not u.is_shadow_banned,
        order_by: [asc: u.first_name, asc: u.last_name]
    )
  end

  @impl true
  def init(_) do
    {
      :ok,
      # %{room_id | :lobby => [{listener_pid, user_id}]}
      %{}
    }
  end

  @impl true
  def handle_call({:join_lobby, user_id}, {from, _}, listeners) do
    rooms = get_room_populations(listeners)

    new_listeners =
      Map.update(listeners, :lobby, [{from, user_id}], fn existing ->
        [{from, user_id} | existing]
      end)

    {:reply, rooms, new_listeners}
  end

  @impl true
  def handle_call({:join, room_id, user_id}, {from, _}, listeners) do
    broadcast_room_event(listeners, :room_join, room_id)

    recent =
      Message
      |> where([m], m.room_id == ^room_id)
      |> join(:inner, [m], u in User, on: m.user_id == u.id)
      |> where([m, u], not u.is_shadow_banned)
      |> limit(100)
      |> order_by([m, u], asc: m.inserted_at)
      |> preload([m, u], user: u)
      |> Repo.all()

    new_listeners =
      Map.update(listeners, room_id, [{from, user_id}], fn existing ->
        [{from, user_id} | existing]
      end)

    {:reply, recent, new_listeners}
  end

  @impl true
  def handle_call({:get_users, room_id}, _from, listeners) do
    user_ids =
      listeners
      |> Map.get(room_id, [])
      |> Enum.map(fn {_pid, user_id} -> user_id end)

    {:reply, user_ids, listeners}
  end

  @impl true
  def handle_cast({:leave_lobby, pid}, listeners) do
    {:noreply,
     Map.update(listeners, :lobby, [], fn existing ->
       Enum.reject(existing, fn {p, _} -> p == pid end)
     end)}
  end

  @impl true
  def handle_cast({:leave, room_id, pid}, listeners) do
    broadcast_room_event(listeners, :room_leave, room_id)

    new_listeners =
      Map.update(listeners, room_id, [], fn existing ->
        Enum.reject(existing, fn {p, _} -> p == pid end)
      end)

    {:noreply, new_listeners}
  end

  @impl true
  def handle_cast({:post, user_id, room_id, body}, listeners) do
    %Message{}
    |> Message.changeset(%{user_id: user_id, room_id: room_id, body: body})
    |> Repo.insert()
    |> case do
      {:error, changeset} ->
        Logger.error("Error inserting message: #{inspect(changeset.errors)}")

      {:ok, message} ->
        message = Repo.preload(message, :user)

        unless message.user.is_shadow_banned do
          broadcast_message(listeners, message)
        end
    end

    {:noreply, listeners}
  end

  defp broadcast_message(listeners, message) do
    for {pid, _} <- Map.get(listeners, message.room_id, []) do
      send(pid, {:message, message})
    end
  end

  defp get_room_populations(listeners) do
    Repo.all(from r in Room, order_by: [asc: r.updated_at])
    |> Enum.map(fn room -> {room, length(Map.get(listeners, room.id, []))} end)
  end

  defp broadcast_room_event(listeners, event, room_id) do
    for {pid, _} <- Map.get(listeners, :lobby, []) do
      send(pid, {event, room_id})
    end
  end
end
