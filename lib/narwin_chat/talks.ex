defmodule NarwinChat.Talks do
  require Logger

  import Ecto.Query

  alias NarwinChat.Dispatcher
  alias NarwinChat.Repo
  alias NarwinChat.Chat.Room
  alias NarwinChat.Chat.Talk

  def list_current_talks(opts \\ []) do
    now = opts[:at] || DateTime.utc_now()

    Talk
    |> where([t], t.starts_at <= ^now and t.ends_at > ^now)
    |> join(:inner, [t], r in Room, on: t.room_id == r.id)
    |> preload([t, r], room: r)
    |> Repo.all()
  end

  def update_talk_rooms(talks) do
    talks
    # Only update the room if the title is changing
    |> Enum.reject(fn talk -> talk.title == talk.room.description end)
    |> Enum.each(fn talk ->
      talk.room
      |> Room.changeset(%{description: talk.title})
      |> Repo.update()
      |> case do
        {:ok, room} ->
          Dispatcher.room_updated(room)

        {:error, _changeset} ->
          Logger.error("Could not update room #{talk.room.id} from talk #{talk.id}")
      end
    end)
  end

  def import_csv(path, opts \\ []) do
    if opts[:clean?] do
      Repo.delete_all(Talk)
    end

    rooms = Repo.all(Room)

    results =
      path
      |> File.stream!()
      |> CSV.decode(headers: true)
      |> Enum.map(&parse_and_insert_talk(&1, rooms))

    ok_count = Enum.count(results, &match?({:ok, _}, &1))
    error_count = Enum.count(results, &match?({:error, _}, &1))

    for {:error, message} <- results do
      Logger.warn(message)
    end

    %{ok: ok_count, error: error_count}
  end

  defp parse_and_insert_talk({:error, message}, _rooms) do
    {:error, message}
  end

  defp parse_and_insert_talk({:ok, row}, rooms) do
    case Enum.find(rooms, &(&1.name == row["room"])) do
      %Room{} = room ->
        insert_talk(row, room)

      nil ->
        {:error,
         "Could not find room #{inspect(row["room"])} for talk #{inspect(row["description"])}"}
    end
  end

  defp insert_talk(row, room) do
    this_year = DateTime.utc_now().year

    # "Aug 31 1:10 PM"
    start_time_naive =
      Timex.parse!(row["start_time"], "{Mshort} {D} {h12}:{m} {AM}") |> Map.put(:year, this_year)

    end_time_naive =
      Timex.parse!(row["end_time"], "{Mshort} {D} {h12}:{m} {AM}") |> Map.put(:year, this_year)

    start_time_mdt = Timex.to_datetime(start_time_naive, "America/Denver")
    end_time_mdt = Timex.to_datetime(end_time_naive, "America/Denver")

    %Talk{}
    |> Talk.changeset(%{
      starts_at: start_time_mdt,
      ends_at: end_time_mdt,
      room_id: room.id,
      title: row["description"]
    })
    |> Repo.insert()
    |> case do
      {:ok, talk} ->
        {:ok, talk}

      {:error, changeset} ->
        {:error, "Could not import talk #{row["name"]}: #{inspect(changeset.errors)}"}
    end
  end
end
