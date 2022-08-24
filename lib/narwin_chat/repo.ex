defmodule NarwinChat.Repo do
  use Ecto.Repo,
    otp_app: :narwin_chat,
    adapter: Ecto.Adapters.Postgres
end
