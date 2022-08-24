defmodule NarwinChat.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Ecto.Changeset

  @type t() :: %__MODULE__{
          id: integer(),
          first_name: String.t(),
          last_name: String.t(),
          email: String.t(),
          is_admin: boolean(),
          is_shadow_banned: boolean(),
          allow_password_login: boolean(),
          password_hash: String.t(),
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
        }

  schema "users" do
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :is_admin, :boolean, default: false
    field :is_shadow_banned, :boolean, default: false
    field :allow_password_login, :boolean, default: false
    field :password, :string, virtual: true
    field :password_hash, :string

    timestamps()
  end

  @optional_params ~w(is_admin is_shadow_banned allow_password_login password password_hash)a
  @required_params ~w(first_name last_name email)a
  @allowed_params @required_params ++ @optional_params

  def changeset(user, params) do
    user
    |> cast(params, @allowed_params)
    |> validate_required(@required_params)
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
    |> maybe_require_password()
    |> put_pass_hash()
  end

  defp maybe_require_password(
         %Changeset{valid?: true, changes: %{allow_password_login: true}} = changeset
       ) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 6)
  end

  defp maybe_require_password(%Changeset{} = changeset), do: changeset

  # ---

  defp put_pass_hash(
         %Changeset{valid?: true, changes: %{allow_password_login: true, password: password}} =
           changeset
       ) do
    change(changeset, Argon2.add_hash(password))
  end

  defp put_pass_hash(%Changeset{} = changeset), do: changeset
end
