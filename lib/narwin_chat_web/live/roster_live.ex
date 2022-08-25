defmodule NarwinChatWeb.RosterLive do
  use NarwinChatWeb, :live_view
  use NarwinChatWeb.LiveViewNativeHelpers, template: "roster_live"
  import Ecto.Query

  alias NarwinChat.{Dispatcher, Repo}
  alias NarwinChat.Accounts.UserBlock
  alias NarwinChat.Chat.Room

  on_mount {NarwinChat.LiveAuth, {false, {:redirect, NarwinChatWeb.LoginLive}, :cont}}

  @impl true
  def render(assigns) do
    render_native(assigns)
  end

  @impl true
  def mount(%{"room" => room_id}, _session, socket) do
    if connected?(socket) do
      # join the lobby so we can observe user join/leave room events
      Dispatcher.join_lobby(socket.assigns.user.id)

      room = Repo.get(Room, String.to_integer(room_id))
      users = Dispatcher.get_users(room.id)

      blocked_users =
        Repo.all(
          from b in UserBlock,
            where: b.blocker_id == ^socket.assigns.user.id,
            select: b.blockee_id
        )

      socket =
        socket
        |> assign(:room, room)
        |> assign(:current_user, socket.assigns.user)
        |> assign(:users, users)
        |> assign(:blocked_users, blocked_users)

      {:ok, socket}
    else
      {:ok, assign(socket, users: [], blocked_users: [])}
    end
  end

  @impl true
  def handle_event("toggle_block_user", blockee_id, socket) when is_binary(blockee_id) do
    handle_event("toggle_block_user", %{"id" => blockee_id}, socket)
  end

  @impl true
  def handle_event("toggle_block_user", %{"id" => blockee_id}, socket) do
    current_user = socket.assigns.user
    blocked_users = socket.assigns.blocked_users
    blockee_id = if is_binary(blockee_id), do: String.to_integer(blockee_id), else: blockee_id
    attempting_to_block_self? = blockee_id == current_user.id

    case blockee_id in blocked_users do
      _ when attempting_to_block_self? ->
        {:noreply, socket}

      true ->
        Repo.delete_all(
          from b in UserBlock,
            where: b.blocker_id == ^socket.assigns.user.id and b.blockee_id == ^blockee_id
        )

        {:noreply, assign(socket, blocked_users: List.delete(blocked_users, blockee_id))}

      false ->
        %UserBlock{}
        |> UserBlock.changeset(%{blocker_id: socket.assigns.user.id, blockee_id: blockee_id})
        |> Repo.insert!()

        {:noreply, assign(socket, blocked_users: [blockee_id | blocked_users])}
    end
  end

  @impl true
  def handle_info({event, room_id}, socket) when event in [:room_join, :room_leave] do
    if room_id == socket.assigns.room.id do
      {:noreply, assign(socket, users: Dispatcher.get_users(room_id))}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def terminate(_reason, _socket) do
    Dispatcher.leave_lobby()
  end
end
