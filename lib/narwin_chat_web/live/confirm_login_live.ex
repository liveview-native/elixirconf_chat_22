defmodule NarwinChatWeb.ConfirmLoginLive do
  use NarwinChatWeb, :live_view
  use NarwinChatWeb.LiveViewNativeHelpers, template: "confirm_login_live"

  alias Ecto.Changeset
  alias NarwinChat.{Accounts, Repo}

  on_mount {NarwinChat.LiveAuth, {false, :cont, {:redirect, NarwinChatWeb.LobbyLive}}}

  @impl true
  def render(assigns) do
    render_native(assigns)
  end

  @impl true
  def mount(params, _session, socket) do
    with %{"user_id" => user_id} <- params,
         %Accounts.UserLogin{} = login <- get_unexpired_user_login(user_id) do
      {
        :ok,
        socket
        |> assign(:user_login, login)
        |> assign(:changeset, Accounts.UserLogin.changeset(login, %{}))
        |> assign(
          :submit_event,
          if(login.user.allow_password_login, do: "confirm_password", else: "confirm_login")
        )
        |> assign(:errors, [])
      }
    else
      _ ->
        {:ok,
         redirect(socket, to: Routes.live_path(NarwinChatWeb.Endpoint, NarwinChatWeb.LoginLive))}
    end
  end

  @impl true
  def handle_event("confirm_login", %{"login_code_confirmation" => _} = login_params, socket) do
    handle_event("confirm_login", %{"user_login" => login_params}, socket)
  end

  @impl true
  def handle_event("confirm_login", %{"user_login" => login_params}, socket) do
    changeset = Accounts.confirm_login_changeset(socket.assigns.changeset, login_params)

    case create_new_user_token(changeset) do
      {:error, changeset} ->
        {:noreply, assign(socket, errors: changeset.errors, submit_event: "confirm_login")}

      {:ok, %Accounts.UserToken{token: token}} ->
        case socket.assigns.platform do
          :ios ->
            Repo.delete(socket.assigns.user_login)
            {:noreply, push_event(socket, "login_token", %{token: token})}

          :web ->
            {:noreply,
             redirect(socket,
               to: Routes.login_path(NarwinChatWeb.Endpoint, :login, login_token: token)
             )}
        end
    end
  end

  @impl true
  def handle_event("confirm_password", %{"password" => _} = login_params, socket) do
    handle_event("confirm_password", %{"user_login" => login_params}, socket)
  end

  @impl true
  def handle_event("confirm_password", %{"user_login" => login_params}, socket) do
    changeset = Accounts.confirm_password_changeset(socket.assigns.changeset, login_params)

    case create_new_user_token(changeset) do
      {:error, changeset} ->
        {:noreply, assign(socket, errors: changeset.errors, submit_event: "confirm_password")}

      {:ok, %Accounts.UserToken{token: token}} ->
        case socket.assigns.platform do
          :ios ->
            {:noreply, push_event(socket, "login_token", %{token: token})}

          :web ->
            {:noreply,
             redirect(socket,
               to: Routes.login_path(NarwinChatWeb.Endpoint, :login, login_token: token)
             )}
        end
    end
  end

  # ---

  defp get_unexpired_user_login(user_id) do
    case Repo.get(Accounts.User, user_id) do
      %Accounts.User{allow_password_login: true} = user ->
        # assign the email too, because UserLogin.changeset expects there to always be an email
        %Accounts.UserLogin{user: user, email: user.email}

      %Accounts.User{allow_password_login: false} = user ->
        with %Accounts.UserLogin{expires_at: expiry} = login <-
               Repo.get(Accounts.UserLogin, user_id),
             :gt <- DateTime.compare(expiry, DateTime.utc_now()) do
          %Accounts.UserLogin{login | user: user}
        else
          _ ->
            nil
        end

      nil ->
        nil
    end
  end

  defp create_new_user_token(%Changeset{valid?: false} = changeset), do: {:error, changeset}

  defp create_new_user_token(%Changeset{} = changeset) do
    Accounts.new_token_changeset(%{
      user_id: Changeset.get_field(changeset, :user).id
    })
    |> Repo.insert()
  end
end
