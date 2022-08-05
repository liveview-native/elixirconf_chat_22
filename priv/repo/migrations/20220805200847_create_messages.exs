defmodule NarwinChat.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table("messages") do
      add :body, :text
      add :room_id, references(:rooms)
      add :user_id, references(:users)

      timestamps()
    end
  end
end
