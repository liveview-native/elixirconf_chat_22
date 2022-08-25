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

  def on_mount(:default, _params, _session, socket) do
    case get_connect_params(socket) do
      %{"_platform" => platform} ->
        platform_key = Map.get(@platforms, platform, :web)

        {:cont, assign(socket, :platform, platform_key)}

      _ ->
        {:cont, assign(socket, :platform, :web)}
    end
  end
end
