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
        |> assign(:users, users)
        |> assign(:blocked_users, blocked_users)

      {:ok, socket}
    else
      {:ok, assign(socket, users: [], blocked_users: [])}
    end
  end

  @impl true
  def handle_event("toggle_block_user", %{"id" => blockee_id}, socket) do
    blocked_users = socket.assigns.blocked_users
    blockee_id = String.to_integer(blockee_id)

    new_blocked_users =
      if blockee_id in blocked_users do
        Repo.delete_all(
          from b in UserBlock,
            where: b.blocker_id == ^socket.assigns.user.id and b.blockee_id == ^blockee_id
        )

        List.delete(blocked_users, blockee_id)
      else
        %UserBlock{}
        |> UserBlock.changeset(%{blocker_id: socket.assigns.user.id, blockee_id: blockee_id})
        |> Repo.insert!()

        [blockee_id | blocked_users]
      end

    {:noreply, assign(socket, blocked_users: new_blocked_users)}
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
