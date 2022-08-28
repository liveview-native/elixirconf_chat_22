defmodule NarwinChat.LoginEmail do
  import Swoosh.Email
  alias NarwinChat.Accounts.UserLogin

  def login(%UserLogin{user: user, login_code: login_code}) do
    new()
    |> to({"#{user.first_name} #{user.last_name}", user.email})
    |> from({"ElixirConf 2022 Chat", "noreply@chatapp.dockyard.com"})
    |> subject("Log in to ElixirConf 2022 Chat")
    |> text_body(
      "Use the following code to log in: #{login_code}\n\nThis code will expire in 1 hour."
    )
  end
end
