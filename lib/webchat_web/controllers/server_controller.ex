defmodule WebchatWeb.ServerController do
  use WebchatWeb, :controller

  alias Webchat.Chat.Servers
  alias Webchat.Chat.Models.Server

  def index(conn, _params) do
    servers = Servers.list()
    render(conn, "index.html", servers: servers)
  end

  def new(conn, _params) do
    changeset = Servers.change(%Server{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"server" => server_params}) do
    case Servers.create(conn.assigns.user, server_params) do
      {:ok, server} ->
        conn
        |> put_flash(:info, "Server created successfully.")
        |> redirect(to: Routes.server_path(conn, :show, server))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    server = Servers.get!(id)
    render(conn, "show.html", server: server)
  end

  def edit(conn, %{"id" => id}) do
    server = Servers.get!(id)
    changeset = Servers.change(server)
    render(conn, "edit.html", server: server, changeset: changeset)
  end

  def update(conn, %{"id" => id, "server" => server_params}) do
    server = Servers.get!(id)

    case Servers.update(server, server_params) do
      {:ok, server} ->
        conn
        |> put_flash(:info, "Server updated successfully.")
        |> redirect(to: Routes.server_path(conn, :show, server))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", server: server, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    server = Servers.get!(id)
    {:ok, _server} = Servers.delete(server)

    conn
    |> put_flash(:info, "Server deleted successfully.")
    |> redirect(to: Routes.server_path(conn, :index))
  end
end
