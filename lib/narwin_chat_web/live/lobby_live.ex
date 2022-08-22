defmodule NarwinChatWeb.LobbyLive do
  use NarwinChatWeb, :live_view
  use NarwinChatWeb.LiveViewNativeHelpers, template: "chat_live"

  alias NarwinChat.Repo
  alias NarwinChat.Chat.Room

  on_mount {NarwinChat.LiveAuth, {false, :redirect_to_login, :cont}}

  @impl true
  def render(assigns) do
    render_native(assigns)
  end

  @impl true
  def mount(_params, _session, socket) do
    # {:ok, assign(socket, rooms: rooms)}
    {:ok, socket}
  end
end
