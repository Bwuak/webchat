defmodule WebchatWeb.ServerController do
  use WebchatWeb, :controller

  alias Webchat.Chat
  alias Webchat.Chat.Server

  def index(conn, _params) do
    servers = Chat.list_servers()
    render(conn, "index.html", servers: servers)
  end

  def new(conn, _params) do
    changeset = Chat.change_server(%Server{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"server" => server_params}) do
    case Chat.create_server(server_params) do
      {:ok, server} ->
        conn
        |> put_flash(:info, "Server created successfully.")
        |> redirect(to: Routes.server_path(conn, :show, server))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    server = Chat.get_server!(id)
    render(conn, "show.html", server: server)
  end

  def edit(conn, %{"id" => id}) do
    server = Chat.get_server!(id)
    changeset = Chat.change_server(server)
    render(conn, "edit.html", server: server, changeset: changeset)
  end

  def update(conn, %{"id" => id, "server" => server_params}) do
    server = Chat.get_server!(id)

    case Chat.update_server(server, server_params) do
      {:ok, server} ->
        conn
        |> put_flash(:info, "Server updated successfully.")
        |> redirect(to: Routes.server_path(conn, :show, server))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", server: server, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    server = Chat.get_server!(id)
    {:ok, _server} = Chat.delete_server(server)

    conn
    |> put_flash(:info, "Server deleted successfully.")
    |> redirect(to: Routes.server_path(conn, :index))
  end
end
