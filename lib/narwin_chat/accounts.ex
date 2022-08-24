defmodule NarwinChat.Accounts do
  alias NarwinChat.Accounts.{UserLogin, UserToken}
  alias NarwinChat.{LoginEmail, Mailer}
  require Logger

  def new_login_changeset(params \\ %{}) do
    UserLogin.changeset(%UserLogin{}, params)
  end

  def confirm_login_changeset(changeset, params) do
    UserLogin.confirmation_changeset(changeset, params)
  end

  def request_login_link(%Ecto.Changeset{data: %UserLogin{}} = login_changeset) do
    if login_changeset.valid? do
      login_changeset
      |> Ecto.Changeset.apply_changes()
      |> LoginEmail.login()
      |> Mailer.deliver()
      |> case do
        {:ok, _} ->
          {:ok, login_changeset}

        {:error, reason} ->
          Logger.error("Error sending login email: #{inspect(reason)}")
          {:error, {:email, {"error sending email", nil}}}
      end

      {:ok, login_changeset}
    else
      {:error, login_changeset.errors}
    end
  end

  def new_token_changeset(params \\ %{}) do
    UserToken.changeset(%UserToken{}, params)
  end
end
