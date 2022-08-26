defmodule NarwinChatWeb.LoginLive do
  use NarwinChatWeb, :live_view
  use NarwinChatWeb.LiveViewNativeHelpers, template: "login_live"
  require Logger

  alias Ecto.Changeset
  alias NarwinChat.{Accounts, Repo}

  on_mount {NarwinChat.LiveAuth, {false, :cont, {:redirect, NarwinChatWeb.LobbyLive}}}

  @impl true
  def render(assigns) do
    render_native(assigns)
  end

  @impl true
  def mount(params, _session, socket) do
    changeset = Accounts.new_login_changeset(params)

    {:ok,
     assign(socket,
       changeset: changeset,
       errors: [],
       submit_event: "login"
     )}
  end

  @impl true
  def handle_event("login", %{"email" => _} = login_params, socket) do
    # native doesn't convert foo[bar] to %{"foo" => %{"bar" => ...}}, so the fields have different names
    handle_event("login", %{"user_login" => login_params}, socket)
  end

  @impl true
  def handle_event("login", %{"user_login" => login_params}, socket) do
    login_params
    |> Accounts.new_login_changeset()
    |> handle_new_login()
    |> case do
      {:ok, changeset, submit_event} ->
        {:noreply,
         assign(socket,
           changeset: changeset,
           errors: [],
           submit_event: submit_event
         )}

      {:error, errors} ->
        {:noreply,
         assign(socket,
           errors: errors,
           submit_event: "login"
         )}
    end
  end

  @impl true
  def handle_event("confirm_login", %{"login_code_confirmation" => _} = login_params, socket) do
    handle_event("confirm_login", %{"user_login" => login_params}, socket)
  end

  @impl true
  def handle_event("confirm_password", %{"password" => _} = login_params, socket) do
    handle_event("confirm_password", %{"user_login" => login_params}, socket)
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

  defp handle_new_login(%Changeset{} = changeset) do
    with {:user, %Accounts.User{allow_password_login: false}} <-
           {:user, Changeset.get_field(changeset, :user)},
         {:ok, changeset} <- Accounts.request_login_link(changeset) do
      Logger.info("[#{inspect(__MODULE__)}] - Login Link Requested - #{inspect(changeset)}")

      {:ok, changeset, "confirm_login"}
    else
      {:user, %Accounts.User{allow_password_login: true}} ->
        Logger.info(
          "[#{inspect(__MODULE__)}] - Login with Password Started - #{inspect(changeset)}"
        )

        {:ok, changeset, "confirm_password"}

      {:user, nil} ->
        {:error, [user: {"no such user", []}]}

      result ->
        result
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
