defmodule NarwinChat.LiveAuth do
  import Phoenix.LiveView

  alias NarwinChat.Repo
  alias NarwinChat.Accounts.UserToken
  alias NarwinChatWeb.Router.Helpers, as: Routes
  alias NarwinChatWeb.{Endpoint, ChatLive, LoginLive}

  def on_mount({require_admin, fail_action, success_action}, _params, session, socket) do
    with token when not is_nil(token) <- get_token(session, socket),
         %UserToken{expires_at: expiry, user: user} <-
           Repo.get_by(UserToken, token: token) |> Repo.preload(:user),
         :gt <- DateTime.compare(expiry, DateTime.utc_now()),
         true <- !require_admin || user.is_admin do
      case success_action do
        :cont ->
          {:cont, assign(socket, user: user)}

        :redirect_to_chat ->
          {:halt, push_redirect(socket, to: Routes.live_path(Endpoint, ChatLive))}
      end
    else
      _ ->
        case fail_action do
          :cont ->
            {:cont, socket}

          :redirect_to_login ->
            {:halt, push_redirect(socket, to: Routes.live_path(Endpoint, LoginLive))}
        end
    end
  end

  defp get_token(session, socket) do
    case get_connect_params(socket) do
      %{"login_token" => token} -> token
      _ -> Map.get(session, "login_token")
    end
  end
end
