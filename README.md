# ElixirConf 2022 Chat

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`
  * Navigate your browser to `localhost:8080` and request a login code with `admin@example.com` and press `continue`
  * Look at the server log for the line `[info] [NarwinChatWeb.LoginLive] - Login Link Requested` and copy the `login_code` value and paste into form
  * After you are authenticated point the browser to `localhost:8080/admin` and create a new room