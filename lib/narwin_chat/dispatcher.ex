defmodule NarwinChat.Dispatcher do
  use GenServer
  require Logger
  import Ecto.Query

  alias NarwinChat.Repo
  alias NarwinChat.Chat.{Room, Message}

  def start_link(opts \\ [name: __MODULE__]) do
    GenServer.start_link(__MODULE__, nil, opts)
  end

  @spec join_lobby() :: %{integer() => integer()}
  def join_lobby() do
    GenServer.call(__MODULE__, :join_lobby)
  end

  @spec leave_lobby() :: :ok
  def leave_lobby() do
    GenServer.cast(__MODULE__, {:leave_lobby, self()})
  end

  @spec join(integer()) :: [Message.t()]
  def join(room_id) do
    GenServer.call(__MODULE__, {:join, room_id})
  end

  @spec leave(integer()) :: :ok
  def leave(room_id) do
    GenServer.cast(__MODULE__, {:leave, room_id, self()})
  end

  @spec post(integer(), integer(), String.t()) :: :ok
  def post(user_id, room_id, body) do
    GenServer.cast(__MODULE__, {:message, user_id, room_id, body, self()})
  end

  @impl true
  def init(_) do
    {
      :ok,
      # %{room_id | :lobby => [listener_pid]}
      %{}
    }
  end

  @impl true
  def handle_call(:join_lobby, {from, _}, listeners) do
    rooms = get_room_populations(listeners)
    new_listeners = Map.update(listeners, :lobby, [from], fn existing -> [from | existing] end)
    {:reply, rooms, new_listeners}
  end

  @impl true
  def handle_call({:join, room_id}, {from, _}, listeners) do
    broadcast_room_event(listeners, :room_join, room_id)

    recent =
      Repo.all(
        from m in Message,
          where: m.room_id == ^room_id,
          order_by: [asc: m.inserted_at],
          limit: 100
      )

    new_listeners = Map.update(listeners, room_id, [from], fn existing -> [from | existing] end)

    {:reply, recent, new_listeners}
  end

  @impl true
  def handle_cast({:leave_lobby, pid}, listeners) do
    {:noreply, Map.update(listeners, :lobby, [], fn existing -> List.delete(existing, pid) end)}
  end

  @impl true
  def handle_cast({:leave, room_id, pid}, listeners) do
    broadcast_room_event(listeners, :room_leave, room_id)

    new_listeners =
      Map.update(listeners, room_id, [], fn existing -> List.delete(existing, pid) end)

    {:noreply, new_listeners}
  end

  @impl true
  def handle_cast({:post, user_id, room_id, body, sender_pid}, listeners) do
    %Message{}
    |> Message.changeset(%{user_id: user_id, room_id: room_id, body: body})
    |> Repo.insert()
    |> case do
      {:error, changeset} ->
        Logger.error("Error inserting message: #{inspect(changeset.errors)}")

      {:ok, message} ->
        broadcast_message(listeners, sender_pid, Repo.preload(message, :user))
    end

    {:noreply, listeners}
  end

  defp broadcast_message(listeners, sender_pid, message) do
    for pid <- Map.get(listeners, message.room_id, []) do
      unless pid == sender_pid do
        send(pid, {:message, message})
      end
    end
  end

  defp get_room_populations(listeners) do
    Repo.all(from r in Room, order_by: [asc: r.name])
    |> Enum.map(fn room -> {room, length(Map.get(listeners, room.id, []))} end)
  end

  defp broadcast_room_event(listeners, event, room_id) do
    for pid <- Map.get(listeners, :lobby, []) do
      send(pid, {event, room_id})
    end
  end
end
