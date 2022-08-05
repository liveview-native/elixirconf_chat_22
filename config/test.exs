import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :narwin_chat, NarwinChatWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "yeD3BkarrgpcHSfpUjwnL1w1sdwkn81auVagV1j5P7IRc49GnzbM3lQTS0RdMbMH",
  server: false

# In test we don't send emails.
config :narwin_chat, NarwinChat.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
