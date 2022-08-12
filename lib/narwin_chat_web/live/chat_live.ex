defmodule NarwinChatWeb.ChatLive do
  use NarwinChatWeb, :live_view
  use NarwinChatWeb.LiveViewNativeHelpers, template: "chat_live"

  @impl true
  def render(assigns) do
    case Map.get(assigns, :platform) do
      :ios ->
        render_ios(assigns)

      :android ->
        render_android(assigns)

      :web ->
        render_web(assigns)
    end
  end

  @impl true
  def mount(_params, _session, socket) do
    with true <- connected?(socket),
         name <- generate_name(),
         {:ok, %{messages: messages}} <- join_chat(name) do
      socket =
        socket
        |> assign(:messages, messages)
        |> assign(:name, name)

      {:ok, socket}
    else
      _ ->
        {:ok, assign(socket, :messages, [])}
    end
  end

  @impl true
  def handle_event("set_buffer", params, socket) do
    {:noreply, assign(socket, :buffer, get_in(params, ["post", "text"]))}
  end

  @impl true
  def handle_event("send", _params, %{assigns: assigns} = socket) do
    send_message(assigns[:buffer])

    {:noreply, assign(socket, :buffer, "")}
  end

  @impl true
  def handle_info({:refresh_state, state}, socket) do
    {:noreply, assign(socket, :messages, state[:messages])}
  end

  @impl true
  def terminate(_reason, _socket) do
    leave_chat()
  end

  ###

  defp join_chat(name) do
    GenServer.call(
      NarwinChat.Store,
      {:join,
       %{
         avatar: "images/narwin.png",
         name: name,
         pid: self()
       }}
    )
  end

  defp leave_chat do
    GenServer.call(NarwinChat.Store, {:leave, self()})
  end

  defp send_message(buffer) do
    GenServer.call(
      NarwinChat.Store,
      {:message,
       %{
         message: buffer,
         pid: self()
       }}
    )
  end

  defp generate_name do
    name = Faker.Color.fancy_name() <> " " <> Faker.Person.first_name()

    name
    |> String.downcase()
    |> Inflex.parameterize()
  end
end
