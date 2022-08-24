defmodule NarwinChat.Repo.Migrations.AddUsersShadowBanned do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :is_shadow_banned, :boolean, default: false
    end
  end
end
