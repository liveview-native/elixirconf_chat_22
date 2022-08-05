defmodule NarwinChat.Chat.Message do
  use Ecto.Schema

  schema "messages" do
    field :body, :string

    belongs_to :user, NarwinChat.Accounts.User
    belongs_to :room, NarwinChat.Chat.Room
  end
end
