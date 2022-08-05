defmodule NarwinChat.Repo.Migrations.CreateRooms do
  use Ecto.Migration

  def change do
    create table("rooms") do
      add :name, :text
      add :description, :text

      timestamps()
    end
  end
end
