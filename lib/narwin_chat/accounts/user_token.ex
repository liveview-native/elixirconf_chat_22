defmodule NarwinChat.Accounts.UserToken do
  use Ecto.Schema
  import Ecto.Changeset
  alias NarwinChat.Accounts.User

  schema "user_tokens" do
    field :token, :string
    field :expires_at, :utc_datetime
    belongs_to :user, User

    timestamps()
  end

  @allowed_params ~w(token user_id)a

  def changeset(user_token, params) do
    user_token
    |> cast(params, @allowed_params)
    |> set_token()
    |> set_expiration()
  end

  defp set_token(changeset) do
    put_change(changeset, :token, :crypto.strong_rand_bytes(32) |> Base.encode64())
  end

  defp set_expiration(changeset) do
    put_change(
      changeset,
      :expires_at,
      DateTime.utc_now()
      |> DateTime.add(60 * 60 * 24 * 7, :second)
      |> DateTime.truncate(:second)
    )
  end
end
