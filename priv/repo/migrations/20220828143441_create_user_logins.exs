defmodule NarwinChat.Repo.Migrations.CreateUserLogins do
  use Ecto.Migration

  def change do
    create table(:user_logins, primary_key: false) do
      add :email, :text
      add :login_code, :text
      add :user_id, references(:users, on_delete: :delete_all), primary_key: true
      add :expires_at, :utc_datetime

      timestamps()
    end
  end
end
