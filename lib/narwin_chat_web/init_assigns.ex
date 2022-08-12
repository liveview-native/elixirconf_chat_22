defmodule NarwinChatWeb.InitAssigns do
  @moduledoc """
  Ensures common `assigns` are applied to all LiveViews attaching this hook.
  """
  import Phoenix.LiveView

  @platforms %{
    "android" => :android,
    "ios" => :ios,
    "web" => :web
  }

  def on_mount(:default, params, _session, socket) do
    platform_key = Map.get(params, "_platform")
    platform = Map.get(@platforms, platform_key, :web)

    {:cont, assign(socket, :platform, platform)}
  end
end
