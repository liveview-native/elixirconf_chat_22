defmodule NarwinChat.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table("users") do
      add :first_name, :text
      add :last_name, :text
      add :email, :text
      add :is_admin, :boolean, default: false

      timestamps()
    end
  end
end
