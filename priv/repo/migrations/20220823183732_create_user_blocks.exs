defmodule NarwinChat.Repo.Migrations.CreateUserBlocks do
  use Ecto.Migration

  def change do
    create table("user_blocks", primary_key: false) do
      add :blocker_id, references(:users, on_delete: :delete_all)
      add :blockee_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:user_blocks, [:blocker_id, :blockee_id])
  end
end
