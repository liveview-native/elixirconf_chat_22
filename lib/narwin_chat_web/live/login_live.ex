defmodule NarwinChatWeb.LoginLive do
  use NarwinChatWeb, :live_view
  use NarwinChatWeb.LiveViewNativeHelpers, template: "login_live"
  require Logger
  import Ecto.Query

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
       errors: []
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
      {:ok, user_login} ->
        {:noreply,
         push_redirect(socket,
           to:
             Routes.live_path(NarwinChatWeb.Endpoint, NarwinChatWeb.ConfirmLoginLive,
               user_id: user_login.user_id
             )
         )}

      {:error, errors} ->
        {:noreply, assign(socket, errors: errors)}
    end
  end

  # ---

  defp handle_new_login(%Changeset{} = changeset) do
    with {:user, %Accounts.User{allow_password_login: false} = user} <-
           {:user, Changeset.get_field(changeset, :user)},
         {:ok, changeset} <- Accounts.request_login_link(changeset) do
      Logger.info("[#{inspect(__MODULE__)}] - Login Link Requested - #{inspect(changeset)}")

      Repo.delete_all(from l in Accounts.UserLogin, where: l.user_id == ^user.id)

      case Repo.insert(changeset) do
        {:ok, user_login} ->
          {:ok, user_login}

        {:error, changeset} ->
          {:error, changeset.errors}
      end
    else
      {:user, %Accounts.User{allow_password_login: true} = user} ->
        Logger.info(
          "[#{inspect(__MODULE__)}] - Login with Password Started - #{inspect(changeset)}"
        )

        {:ok, %Accounts.UserLogin{user_id: user.id}}

      {:user, nil} ->
        {:error, [user: {"no such user", []}]}

      result ->
        result
    end
  end
end
