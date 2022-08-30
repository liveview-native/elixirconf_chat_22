defmodule NarwinChat.Repo.Migrations.CreateTalks do
  use Ecto.Migration

  def change do
    create table(:talks) do
      add :starts_at, :utc_datetime, null: false
      add :ends_at, :utc_datetime, null: false
      add :title, :string, null: false
      add :room_id, references(:rooms, on_delete: :restrict), null: false

      timestamps()
    end

    create index(:talks, [:room_id])
  end
end
