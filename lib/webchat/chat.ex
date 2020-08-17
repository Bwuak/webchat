defmodule Webchat.Chat do
  import Ecto.Query, warn: false

  alias Webchat.Chat.Models.Chatroom
  alias Webchat.Chat.Models.Server
  alias Webchat.Chat.Servers
  alias Webchat.Chat.Chatrooms


  # First server for a given list of servers
  def select_default_server([]), do: %Server{name: nil}
  def select_default_server([head | _tail]), do: head

  # First chatroom for a given list of chatrooms
  def select_default_chatroom([]), do: %Chatroom{roomname: :nil}
  def select_default_chatroom([head | _tail]), do: head

  # get the owner of a server
  def owner_of(%Server{} = server), do: Servers.with_user(server).user

  # Checks if user is owner 
  # TODO Participant or user? TBD
  def is_owner_of?(%Server{} = server, user) do
    user == owner_of(server)
  end

end
