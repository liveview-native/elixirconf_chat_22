defmodule NarwinChat.Repo.Migrations.CreateUserTokens do
  use Ecto.Migration

  def change do
    create table("user_tokens") do
      add :token, :text
      add :expires_at, :utc_datetime
      add :user_id, references(:users)

      timestamps()
    end
  end
end
