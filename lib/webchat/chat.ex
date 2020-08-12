defmodule Webchat.Chat do
  import Ecto.Query, warn: false

  alias Webchat.Chat.Models.Chatroom
  alias Webchat.Chat.Models.Server
  alias Webchat.Chat.Servers


  def select_chatrooms(server) do
    if server.id == :nil, 
      do: [], 
      else: Enum.reverse( Servers.with_chatrooms(server).chatrooms )
  end

  def select_default_server(servers) do
    if servers == [], 
      do: select_null_server(), else: servers |> Enum.at(0)
  end

  def select_default_chatroom([]), do: select_null_chatroom() 
  def select_default_chatroom([head|_tail]), do: head

  defp select_null_chatroom(), do: %Chatroom{roomname: :nil} 

  defp select_null_server(), do: %Server{name: :nil} 

end
