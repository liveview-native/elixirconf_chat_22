defmodule NarwinChatWeb.ChatLive do
  use NarwinChatWeb, :live_view
  use NarwinChatWeb.LiveViewNativeHelpers, template: "chat_live"
  import Ecto.Query

  alias NarwinChat.{Dispatcher, Repo}
  alias NarwinChat.Accounts.UserBlock
  alias NarwinChat.Chat.Room

  on_mount {NarwinChat.LiveAuth, {false, {:redirect, NarwinChatWeb.LoginLive}, :cont}}

  @config Expletive.configure(blacklist: Expletive.Blacklist.english)

  @impl true
  def render(assigns) do
    render_native(assigns)
  end

  @impl true
  def mount(%{"room" => room_id}, _session, socket) do
    if connected?(socket) do
      room = Repo.get(Room, String.to_integer(room_id))

      blocked_users =
        Repo.all(
          from b in UserBlock,
            where: b.blocker_id == ^socket.assigns.user.id,
            select: b.blockee_id
        )

      messages =
        Dispatcher.join(room.id, socket.assigns.user.id)
        |> Enum.reject(fn msg -> msg.user.id in blocked_users end)

      socket =
        socket
        |> assign(:messages, messages)
        |> assign(:room, room)
        |> assign(:blocked_users, blocked_users)
        |> push_event(:message_added, %{force_scroll: true})

      {:ok, socket}
    else
      {:ok, assign(socket, :messages, [])}
    end
  end

  @impl true
  def handle_event("send", %{"text" => body}, %{assigns: assigns} = socket) do
    sanitized_body = Expletive.sanitize(body, @config)
    Dispatcher.post(assigns.user.id, assigns.room.id, sanitized_body)

    {:noreply, push_event(socket, :clear_message_field, %{})}
  end

  @impl true
  def handle_info({:message, message}, socket) do
    if message.user.id in socket.assigns.blocked_users do
      {:noreply, socket}
    else
      {:noreply,
       socket
       |> assign(:messages, socket.assigns.messages ++ [message])
       |> push_event(:message_added, %{})}
    end
  end

  @impl true
  def terminate(_reason, socket) do
    case socket.assigns do
      %{room: room} ->
        Dispatcher.leave(room.id)

      _ ->
        :ok
    end
  end

  ###
end
