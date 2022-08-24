defmodule NarwinChat.Repo.Migrations.AddPasswordLoginFieldsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :allow_password_login, :boolean, default: false
      add :password_hash, :text
    end
  end
end
