defmodule NarwinChat.Chat.Room do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rooms" do
    field :name, :string
    field :description, :string

    timestamps()
  end

  @required_params ~w(name description)a

  def changeset(room, params) do
    room
    |> cast(params, @required_params)
    |> validate_required(@required_params)
  end
end
