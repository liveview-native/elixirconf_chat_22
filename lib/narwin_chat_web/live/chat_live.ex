defmodule NarwinChatWeb.ChatLive do
  use NarwinChatWeb, :live_view
  use NarwinChatWeb.LiveViewNativeHelpers, template: "chat_live"

  alias NarwinChat.{Dispatcher, Repo}
  alias NarwinChat.Chat.Room

  on_mount {NarwinChat.LiveAuth, {false, {:redirect, NarwinChatWeb.LoginLive}, :cont}}

  @impl true
  def render(assigns) do
    render_native(assigns)
  end

  @impl true
  def mount(%{"room" => room_id}, _session, socket) do
    if connected?(socket) do
      room = Repo.get(Room, String.to_integer(room_id))
      messages = Dispatcher.join(room.id)

      socket =
        socket
        |> assign(:messages, messages)
        |> assign(:room, room)
        |> push_event(:message_added, %{force_scroll: true})

      {:ok, socket}
    else
      {:ok, assign(socket, :messages, [])}
    end
  end

  @impl true
  def handle_event("set_buffer", params, socket) do
    {:noreply, assign(socket, :buffer, get_in(params, ["post", "text"]))}
  end

  @impl true
  def handle_event("send", _params, %{assigns: assigns} = socket) do
    send_message(assigns[:buffer])
    Dispatcher.post(assigns.user.id, assigns.room.id, assigns.buffer)

    {:noreply, assign(socket, :buffer, "")}
  end

  @impl true
  def handle_info({:message, message}, socket) do
    {:noreply,
     socket
     |> assign(:messages, socket.assigns.messages ++ [message])
     |> push_event(:message_added, %{})}
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

  defp send_message(buffer) do
    GenServer.call(
      NarwinChat.Store,
      {:message,
       %{
         message: buffer,
         pid: self()
       }}
    )
  end
end
