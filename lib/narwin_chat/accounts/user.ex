defmodule NarwinChat.Accounts.User do
  use Ecto.Schema

  schema "users" do
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :is_admin, :boolean, default: false

    timestamps()
  end
end
