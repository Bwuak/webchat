defmodule Webchat.Chat.Servers do
  import Ecto.Query, warn: false

  alias Webchat.Repo
  alias Webchat.Chat.Models.Server
  alias Webchat.Chat.Models.Chatroom

  def list do
    Repo.all(Server)
  end

  def get!(id), do: Repo.get!(Server, id)
  def get(id), do: Repo.get!(Server, id)

  def create_server(attrs) do
    %Server{}
    |> Server.changeset(attrs)
    |> Repo.insert()
  end

  def update_server(%Server{} = server, attrs) do
    server
    |> Server.changeset(attrs)
    |> Repo.update()
  end

  def delete_server(%Server{} = server) do
    Repo.delete(server)
  end

  def change_server(%Server{} = server, attrs \\ %{}) do
    Server.changeset(server, attrs)
  end

  def with_chatrooms(%Server{} = server) do
    # Preloading chatrooms in creation order
    Repo.preload(server, [chatrooms: from(c in Chatroom, order_by: c.id)] )
  end

  # server.user => server's owner
  def with_user(%Server{} = server) do
    Repo.preload(server, :user)
  end

end
