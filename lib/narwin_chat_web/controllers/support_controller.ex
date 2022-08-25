defmodule NarwinChatWeb.SupportController do
  use NarwinChatWeb, :controller

  alias NarwinChat.{SupportMessage, Repo}

  def support(conn, _params) do
    conn
    |> assign(:received, false)
    |> render("support.html")
  end

  def support_form_submit(conn, %{"email" => email, "message" => message}) do
    %SupportMessage{}
    |> SupportMessage.changeset(%{"email" => email, "message" => message})
    |> Repo.insert()

    conn
    |> assign(:received, true)
    |> render("support.html")
  end

  def privacy_policy(conn, _params) do
    render(conn, "privacy_policy.html")
  end
end
