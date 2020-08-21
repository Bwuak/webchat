defmodule WebchatWeb.UserController do
  use WebchatWeb, :controller

  alias WebchatWeb.Endpoint

  alias Webchat.Administration.Users
  alias Webchat.Administration.Models.User


  def index(conn, _params) do
    users = Users.list()
    render(conn, "index.html", users: users)
  end

  def new(conn, _params) do
    changeset = Users.change(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Users.create(user_params) do
      {:ok, user} ->
        conn
        |> WebchatWeb.Auth.login(user)
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: "/chat") 

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Users.get!(id)
    {:ok, _user} = Users.delete(user)

    # Disconnecting the deleted user's sockets
    Endpoint.broadcast("users_socket: #{user.id}", "disconnect", %{})

    conn
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: Routes.user_path(conn, :index))
  end

end
