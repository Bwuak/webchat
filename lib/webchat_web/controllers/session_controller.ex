defmodule WebchatWeb.SessionController do
  use WebchatWeb, :controller

  alias Webchat.Administration

  def new(conn, _) do
    render(conn, "new.html")
  end

  def create(conn,
      %{"session" => %{"email" => email, "password" => password} } ) do
    case Administration.authenticate_user(email, password) do
      {:ok, user} ->
        conn
        |> WebchatWeb.Auth.login(user)
        |> put_flash(:info, "Succesful login!")
        |> redirect(to: "/chat")

      {:error, _reason} ->
        conn
        |> put_flash(:error, "Invalid login information")
        |> render("new.html")
    end
  end

  def delete(conn, _) do
    conn
    |> WebchatWeb.Auth.logout()
    |> redirect(to: Routes.page_path(conn, :index))
  end

end
