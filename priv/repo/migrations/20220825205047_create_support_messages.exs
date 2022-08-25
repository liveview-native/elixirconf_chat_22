defmodule NarwinChat.Repo.Migrations.CreateSupportMessages do
  use Ecto.Migration

  def change do
    create table(:support_messages) do
      add :email, :text
      add :message, :text
      timestamps()
    end
  end
end
