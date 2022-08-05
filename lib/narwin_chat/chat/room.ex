defmodule NarwinChat.Chat.Room do
  use Ecto.Schema

  schema "rooms" do
    field :name, :string
    field :description, :string
  end
end
