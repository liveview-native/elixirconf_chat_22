defmodule NarwinChatWeb.LoginLive do
  use NarwinChatWeb, :live_view
  use NarwinChatWeb.LiveViewNativeHelpers, template: "login_live"
  require Logger

  alias NarwinChat.Accounts

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
  def handle_event("login", %{"user_login" => login_params}, socket) do
    login_params
    |> Accounts.new_login_changeset()
    |> Accounts.request_login_link()
    |> case do
      {:ok, changeset} ->
        Logger.info("[#{inspect(__MODULE__)}] - Login Link Requested - #{inspect(changeset)}")

        {:noreply,
         assign(socket,
           changeset: changeset,
           errors: [],
           submit_event: "confirm_login"
         )}

      {:error, errors} ->
        {:noreply,
         assign(socket,
           errors: errors,
           submit_event: "login"
         )}
    end
  end
end
