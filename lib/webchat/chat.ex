defmodule Webchat.Chat do
  import Ecto.Query, warn: false

  alias Webchat.Chat.Models.Chatroom
  alias Webchat.Chat.Models.Server
  alias Webchat.Chat.Servers


  @doc """
  Get a server with it's id
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
  Checks if user is owner 
  """
  def is_owner?(%Server{} = server, user) do
    server.user_id == user.id
  end

end
