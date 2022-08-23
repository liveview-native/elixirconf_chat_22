defmodule NarwinChat.Accounts.UserBlock do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  schema "user_blocks" do
    belongs_to :blocker, NarwinChat.Accounts.User
    belongs_to :blockee, NarwinChat.Accounts.User

    timestamps()
  end

  @required_params ~w(blocker_id blockee_id)a

  def changeset(block, params) do
    block
    |> cast(params, @required_params)
    |> validate_required(@required_params)
    |> unique_constraint([:blocker_id, :blockee_id])
  end
end
