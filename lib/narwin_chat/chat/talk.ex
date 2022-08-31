defmodule NarwinChat.Chat.Talk do
  use Ecto.Schema
  import Ecto.Changeset

  schema "talks" do
    field :ends_at, :utc_datetime
    field :starts_at, :utc_datetime
    field :title, :string
    belongs_to :room, NarwinChat.Chat.Room

    timestamps()
  end

  @required_params ~w(starts_at ends_at title room_id)a

  @doc false
  def changeset(talk, attrs) do
    talk
    |> cast(attrs, @required_params)
    |> validate_required(@required_params)
  end
end
