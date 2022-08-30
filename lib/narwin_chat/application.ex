defmodule NarwinChat.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      NarwinChat.Repo,
      # Start the Telemetry supervisor
      NarwinChatWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: NarwinChat.PubSub},
      # Start the Endpoint (http/https)
      NarwinChatWeb.Endpoint,
      # Start a worker by calling: NarwinChat.Worker.start_link(arg)
      # {NarwinChat.Worker, arg}
      {NarwinChat.Store, name: NarwinChat.Store},
      {NarwinChat.Dispatcher, name: NarwinChat.Dispatcher},
      NarwinChat.RoomTalkUpdater
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: NarwinChat.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    NarwinChatWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
