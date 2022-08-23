defmodule NarwinChat.Chat.Message do
  use Ecto.Schema
  import Ecto.Changeset

  @type t() :: %__MODULE__{
          body: String.t(),
          user_id: integer(),
          room_id: integer(),
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
        }

  schema "messages" do
    field :body, :string

    belongs_to :user, NarwinChat.Accounts.User
    belongs_to :room, NarwinChat.Chat.Room

    timestamps()
  end

  @required_params ~w(body user_id room_id)a

  def changeset(message, params) do
    message
    |> cast(params, @required_params)
    |> validate_required(@required_params)
  end
end
