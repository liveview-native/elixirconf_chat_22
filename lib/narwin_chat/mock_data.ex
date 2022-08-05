defmodule NarwinChat.MockData do
  @mock_users [
    %{name: "Mario", id: "mario"},
    %{name: "Luigi", id: "luigi"},
    %{name: "Peach", id: "peach"},
    %{name: "Link", id: "link"},
    %{name: "Zelda", id: "zelda"}
  ]
  @mock_messages [
    "Hey what's up",
    "Hihihihi",
    "POGGERS",
    "lfg",
    "sup all I'm new",
    "What's going on?"
  ]

  def messages(n \\ 100) do
    nil
    |> List.duplicate(n)
    |> Enum.map(fn _ -> message() end)
  end

  def message do
    %{
      id: Ecto.UUID.generate(),
      text: Enum.random(@mock_messages),
      user: Enum.random(@mock_users)
    }
  end
end
