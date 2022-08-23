defmodule NarwinChatWeb.LobbyLive do
  use NarwinChatWeb, :live_view
  use NarwinChatWeb.LiveViewNativeHelpers, template: "lobby_live"

  alias NarwinChat.Dispatcher
  alias NarwinChat.Chat.Room

  on_mount {NarwinChat.LiveAuth, {false, {:redirect, NarwinChatWeb.LoginLive}, :cont}}

  @impl true
  def render(assigns) do
    render_native(assigns)
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      {:ok, assign(socket, rooms: Dispatcher.join_lobby())}
    else
      {:ok, assign(socket, rooms: [])}
    end
  end

  @impl true
  def handle_info({event, room_id}, socket) when event in [:room_join, :room_leave] do
    index = Enum.find_index(socket.assigns.rooms, fn {%Room{id: id}, _} -> id == room_id end)
    delta = if event == :room_join, do: 1, else: -1

    new_rooms =
      List.update_at(socket.assigns.rooms, index, fn {room, count} -> {room, count + delta} end)

    {:noreply, assign(socket, rooms: new_rooms)}
  end

  @impl true
  def terminate(_reason, _socket) do
    Dispatcher.leave_lobby()
  end
end
