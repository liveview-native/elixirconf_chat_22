defmodule NarwinChat.SupportMessage do
  use Ecto.Schema
  import Ecto.Changeset

  schema "support_messages" do
    field :email, :string
    field :message, :string

    timestamps()
  end

  @required_params ~w(email message)a

  def changeset(message, params) do
    message
    |> cast(params, @required_params)
    |> validate_required(@required_params)
  end
end
