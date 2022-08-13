defmodule NarwinChat.Accounts do
  alias NarwinChat.Accounts.UserLogin

  def new_login_changeset(params \\ %{}) do
    UserLogin.changeset(%UserLogin{}, params)
  end

  def request_login_link(%Ecto.Changeset{data: %UserLogin{}} = login_changeset) do
    if login_changeset.valid? do
      {:ok, login_changeset}
    else
      {:error, login_changeset.errors}
    end
  end
end
