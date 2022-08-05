defmodule NarwinChatWeb.PageController do
  use NarwinChatWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
