defmodule NarwinChatWeb.LoginController do
  use NarwinChatWeb, :controller

  def login(conn, %{"login_token" => token}) do
    conn
    |> put_session(:login_token, token)
    |> redirect(to: Routes.live_path(conn, NarwinChatWeb.ChatLive))
  end
end
