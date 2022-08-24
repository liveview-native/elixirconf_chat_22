defmodule NarwinChat.Repo.Migrations.CreateIndexes do
  use Ecto.Migration

  def change do
    create unique_index(:users, [:email])
    create index(:user_tokens, [:token])
    create index(:messages, [:room_id])
  end
end
