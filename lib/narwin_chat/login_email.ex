defmodule NarwinChat.LoginEmail do
  import Swoosh.Email
  alias NarwinChat.Accounts.UserLogin

  def login(%UserLogin{user: user, login_code: login_code}) do
    new()
    |> to({"#{user.first_name} #{user.last_name}", user.email})
    |> from({"NarwinChat", "noreply@example.com"})
    |> subject("Log in to NarwinChat")
    |> text_body("Use the following code to log in: #{login_code}")
  end
end
