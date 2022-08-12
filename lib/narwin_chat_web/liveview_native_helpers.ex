defmodule NarwinChatWeb.LiveViewNativeHelpers do
  defmacro __using__(opts \\ []) do
    template = Keyword.fetch!(opts, :template)

    quote do
      require EEx

      EEx.function_from_file(
        :defp,
        :render_web,
        "lib/narwin_chat_web/live/#{unquote(template)}.html.heex",
        [:assigns],
        engine: Phoenix.LiveView.HTMLEngine
      )

      EEx.function_from_file(
        :defp,
        :render_android,
        "lib/narwin_chat_web/live/#{unquote(template)}.android.heex",
        [:assigns],
        engine: Phoenix.LiveView.HTMLEngine
      )

      EEx.function_from_file(
        :defp,
        :render_ios,
        "lib/narwin_chat_web/live/#{unquote(template)}.ios.heex",
        [:assigns],
        engine: Phoenix.LiveView.HTMLEngine
      )
    end
  end
end
