defmodule NarwinChat.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table("messages") do
      add :body, :text
      add :room_id, references(:rooms, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end
  end
end
