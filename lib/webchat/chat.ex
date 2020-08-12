defmodule Webchat.Chat do
  import Ecto.Query, warn: false

  alias Webchat.Chat.Models.Chatroom
  alias Webchat.Chat.Models.Server
  alias Webchat.Chat.Servers


  def select_chatrooms(%Server{} = server) do
    Enum.reverse( Servers.with_chatrooms(server).chatrooms )
  end

  def select_default_server([]), do: %Server{name: nil}
  def select_default_server([head | _tail]), do: head

  def select_default_chatroom([]), do: %Chatroom{roomname: :nil}
  def select_default_chatroom([head | _tail]), do: head

end
