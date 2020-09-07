defmodule Webchat.Chat do
  import Ecto.Query, warn: false

  alias Webchat.Repo
  alias Webchat.Administration.Models.User
  alias Webchat.Chat.Models.Chatroom
  alias Webchat.Chat.Models.Server
  alias Webchat.Chat.Models.Participant
  alias Webchat.Chat.Servers


  @doc """
  Get a server 
  loaded with it's chatrooms
  """
  def select_server(serverId) do
    Servers.get!(serverId)
    |> Servers.with_chatrooms()
  end

  @doc """
  Select a chatroom from a server
  - The server must have loaded it's chatrooms
  Select the server before the chatroom

  Returns found chatroom or nil
  """
  def select_chatroom(%Server{} = server, roomId)
      when is_integer(roomId) do
    server.chatrooms
    |> Enum.find(&(&1.id == roomId))
  end

  def select_chatroom(s, roomId) do
    select_chatroom(s, String.to_integer(roomId))
  end

  @doc """
  First server for a given list of servers
  """
  def select_default_server([]), do: %Server{name: nil, chatrooms: []}
  def select_default_server([head | _tail]), do: Servers.with_chatrooms(head)

  @doc """
  First chatroom for a given list of chatrooms
  """
  def select_default_chatroom([]), do: %Chatroom{roomname: nil}
  def select_default_chatroom([head | _tail]), do: head


  @doc """
  Get all participants inside a server
  """
  def list_participants(%Server{} = server) do
    from( p in Participant,
      where: p.server_id == ^server.id,
      preload: [:user]
    )
    |> Repo.all()
  end

  @doc """
  List servers associated with given user
  """
  def list_servers(%User{} = user) do
    from( s in Server,
      join: p in Participant,
      on: p.server_id == s.id,
      where: p.user_id == ^user.id
    )
    |> Repo.all()
  end

end
