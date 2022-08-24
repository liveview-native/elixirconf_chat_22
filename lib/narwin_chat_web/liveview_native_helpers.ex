defmodule NarwinChatWeb.LiveViewNativeHelpers do
  defmacro __using__(opts \\ []) do
    template = Keyword.fetch!(opts, :template)

    quote bind_quoted: [template: template] do
      require EEx

      def render_native(assigns) do
        case assigns do
          %{platform: :web} ->
            render_web(assigns)

          %{platform: :ios} ->
            render_ios(assigns)

          %{platform: :android} ->
            render_android(assigns)

          _ ->
            render_blank(assigns)
        end
      end

      EEx.function_from_file(
        :defp,
        :render_android,
        "lib/narwin_chat_web/live/#{template}/#{template}.android.heex",
        [:assigns],
        engine: Phoenix.LiveView.HTMLEngine
      )

      EEx.function_from_file(
        :defp,
        :render_ios,
        "lib/narwin_chat_web/live/#{template}/#{template}.ios.heex",
        [:assigns],
        engine: Phoenix.LiveView.HTMLEngine
      )

      EEx.function_from_file(
        :defp,
        :render_web,
        "lib/narwin_chat_web/live/#{template}/#{template}.html.heex",
        [:assigns],
        engine: Phoenix.LiveView.HTMLEngine
      )

      EEx.function_from_file(
        :defp,
        :render_blank,
        "lib/narwin_chat_web/live/blank.html.heex",
        [:assigns],
        engine: Phoenix.LiveView.HTMLEngine
      )
    end
  end
end
