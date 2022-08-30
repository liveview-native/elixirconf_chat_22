defmodule NarwinChat.RoomTalkUpdater do
  use GenServer

  alias NarwinChat.Talks

  def start_link(_) do
    GenServer.start_link(__MODULE__, [])
  end

  @impl true
  def init(_) do
    send(self(), :tick)
    {:ok, %{}}
  end

  @impl true
  def handle_info(:tick, state) do
    update_rooms()
    schedule_tick()
    {:noreply, state}
  end

  defp update_rooms do
    talks = Talks.list_current_talks()
    Talks.update_talk_rooms(talks)
  end

  defp schedule_tick do
    Process.send_after(self(), :tick, 60_000)
  end
end
