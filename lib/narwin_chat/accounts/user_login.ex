defmodule NarwinChat.Accounts.UserLogin do
  use Ecto.Schema
  import Ecto.Changeset

  alias NarwinChat.Repo
  alias NarwinChat.Words
  alias NarwinChat.Accounts.User

  embedded_schema do
    field :email, :string
    field :login_code, :string, virtual: true
    field :login_code_confirmation, :string

    embeds_one :user, User
  end

  @optional_params ~w(login_code_confirmation)a
  @required_params ~w(email)a

  @allowed_params @optional_params ++ @required_params

  def changeset(user_login, params \\ %{}) do
    user_login
    |> cast(params, @allowed_params)
    |> validate_required(@required_params)
    |> validate_format(:email, ~r/@/)
    |> attach_login_code()
    |> attach_user()
  end

  ###

  defp attach_login_code(%Ecto.Changeset{valid?: true} = changeset) do
    put_change(changeset, :login_code, generate_login_code())
  end

  defp attach_login_code(changeset), do: changeset

  defp attach_user(%Ecto.Changeset{valid?: true} = changeset) do
    email = get_field(changeset, :email)
    user = Repo.get_by(User, email: email)

    put_change(changeset, :user, user)
  end

  defp attach_user(changeset), do: changeset

  defp generate_login_code do
    Enum.join([Words.random_big(), Words.random_big(), Words.random_big()], "-")
  end
end
