defmodule Webchat.Chat.Servers do
  import Ecto.Query, warn: false

  alias Webchat.Repo
  alias Webchat.Administration.Models.User
  alias Webchat.Chat.Models.Server
  alias Webchat.Chat.Models.Chatroom

  def list, do: Repo.all(Server)

  def get!(id), do: Repo.get!(Server, id)

  def get(id), do: Repo.get(Server, id)

  def delete(%Server{} = server), do: Repo.delete(server)

  def create(%User{} = user, attrs) do
    %Server{user_id: user.id}
    |> Server.changeset(attrs)
    |> Repo.insert()
  end

  def update(%Server{} = server, attrs) do
    server
    |> Server.changeset(attrs)
    |> Repo.update()
  end
  
  def change(%Server{} = server, attrs \\ %{}) do
    Server.changeset(server, attrs)
  end

  @doc """
  Load the server with it's chatrooms
  """
  def with_chatrooms(%Server{} = server) do
    # Preloading chatrooms in creation order
    Repo.preload(server, [chatrooms: from(c in Chatroom, order_by: c.id)] )
  end

  @doc """
  Load the server with it's owner
  """
  def with_user(%Server{} = server) do
    Repo.preload(server, :owner)
  end

end
