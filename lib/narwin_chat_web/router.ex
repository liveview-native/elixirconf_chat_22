defmodule NarwinChatWeb.Router do
  use NarwinChatWeb, :router

  alias NarwinChat.Repo
  alias NarwinChat.Accounts.User
  alias NarwinChat.Accounts.UserToken

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {NarwinChatWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :admin do
    plug :ensure_admin
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/admin", NarwinChatWeb do
    pipe_through [:browser, :admin]

    live "/", AdminLive
  end

  scope "/", NarwinChatWeb do
    pipe_through :browser

    get "/login", LoginController, :login
    get "/support", SupportController, :support
    post "/support", SupportController, :support_form_submit
    get "/privacy", SupportController, :privacy_policy

    live_session :default, on_mount: NarwinChatWeb.InitAssigns do
      live "/", LoginLive
      live "/confirm", ConfirmLoginLive
      live "/lobby", LobbyLive
      live "/room/:room", ChatLive
      live "/room/:room/roster", RosterLive
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", NarwinChatWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: NarwinChatWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  # ---

  defp ensure_admin(conn, _opts) do
    with token when is_binary(token) <- get_session(conn, "login_token"),
         %UserToken{} = user_token <- Repo.get_by(UserToken, token: token),
         %UserToken{expires_at: expiry, user: user} <- Repo.preload(user_token, :user),
         :gt <- DateTime.compare(expiry, DateTime.utc_now()),
         true <- user.is_admin do
      conn
    else
      _ ->
        conn
        |> halt()
        |> redirect(to: "/")
    end
  end
end
