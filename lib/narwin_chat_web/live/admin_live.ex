defmodule NarwinChatWeb.AdminLive do
  use NarwinChatWeb, :live_view
  import Ecto.Query

  alias NarwinChat.{Repo, SupportMessage}
  alias NarwinChat.Accounts.User
  alias NarwinChat.Chat.Room

  on_mount {NarwinChat.LiveAuth, {true, {:redirect, NarwinChatWeb.LoginLive}, :cont}}

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(
       successfully_created_users: 0,
       csv_errors: [],
       shadow_banned: get_shadow_banned_users(),
       rooms: get_rooms(),
       support_messages: Repo.all(SupportMessage)
     )
     |> allow_upload(:users_csv, accept: [".csv"])}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("load_users", _params, socket) do
    [{successful, errors}] =
      consume_uploaded_entries(socket, :users_csv, fn %{path: path}, _entry ->
        {:ok,
         path
         |> File.stream!()
         |> CSV.decode(headers: true)
         |> Enum.reduce({0, []}, fn row, {count, errors} ->
           case row do
             {:ok, params} ->
               %User{}
               |> User.changeset(params)
               |> Repo.insert()
               |> case do
                 {:ok, _} ->
                   {count + 1, errors}

                 {:error, changest} ->
                   first_name = Map.get(params, "first_name", "")
                   last_name = Map.get(params, "last_name", "")
                   email = Map.get(params, "email", "")

                   {count,
                    [
                      "Error inserting '#{first_name} #{last_name}' <#{email}>: #{inspect(changest.errors)}"
                      | errors
                    ]}
               end

             {:error, reason} ->
               {count, [reason | errors]}
           end
         end)}
      end)

    {:noreply, assign(socket, successfully_created_users: successful, csv_errors: errors)}
  end

  @impl true
  def handle_event("set_shadow_banned", %{"email" => email, "banned" => banned}, socket) do
    is_banned = banned == "true"

    from(u in User)
    |> where([u], u.email == ^email)
    |> update(set: [is_shadow_banned: ^is_banned])
    |> Repo.update_all([])

    {:noreply, assign(socket, shadow_banned: get_shadow_banned_users())}
  end

  @impl true
  def handle_event("add_room", params, socket) do
    %Room{}
    |> Room.changeset(params)
    |> Repo.insert!()

    {:noreply, assign(socket, rooms: get_rooms())}
  end

  @impl true
  def handle_event("delete_room", %{"id" => id}, socket) do
    Room
    |> Repo.get(id)
    |> Repo.delete()

    {:noreply, assign(socket, rooms: get_rooms())}
  end

  defp get_shadow_banned_users() do
    Repo.all(
      from u in User,
        where: u.is_shadow_banned == true,
        order_by: [asc: u.first_name, asc: u.last_name]
    )
  end

  defp get_rooms() do
    Repo.all(from r in Room, order_by: [asc: r.name])
  end
end
