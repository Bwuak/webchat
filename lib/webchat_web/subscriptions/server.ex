defmodule WebchatWeb.Subscriptions.Server do
  alias Phoenix.LiveView
  alias WebchatWeb.Presence
  alias WebchatWeb.Endpoint

  alias Webchat.Chat.Models.Server
  alias Webchat.Chat.ServerParticipation


  @topic_prefix "server:"
  # turn a given serverId into a valid topic string
  def topic(serverId) when is_integer(serverId) do
    @topic_prefix <> Integer.to_string(serverId)
  end

  def topic(serverId) when is_bitstring(serverId) do 
    @topic_prefix <> serverId
  end
  
  def subscribe_to_server(server, socket) when is_nil(server), do: socket 
  def subscribe_to_server(%Server{} = server, socket) do
    socket = unsubscribe_to_server(socket.assigns.subscription, socket)
    case server.id do
      nil ->
        socket
      id ->
        topic = topic(id) 
        Endpoint.subscribe(topic)
        LiveView.assign(socket, 
          subscription: topic,
          users: participants_list(server)
        ) 
    end
  end

  def unsubscribe_to_server(topic, socket) when is_nil(topic) do 
    socket 
  end

  def unsubscribe_to_server(topic, socket) do
    Endpoint.unsubscribe(topic)
    LiveView.assign(socket, subscription: nil)
  end

  def participants_list(%Server{} = server) do
    all = all_participants(server)
    onlines = online_participants(topic(server.id)) 
    
    for p <- all, into: [] do
      if onlines[Integer.to_string(p.user_id)] do
        %{username: p.user.username,
          status: "online"}
      else
        %{username: p.user.username,
          status: "offline"}
      end
    end
    |> sort_participants()
  end

  # Sort by
  # First letter of username
  # Status -> online or offline
  defp sort_participants(participants) do
    participants
    |> Enum.sort_by( &( String.at(&1.username, 0) ))
    |> Enum.reverse()
    |> Enum.sort_by( &(&1.status) ) 
    |> Enum.reverse()
  end 

  defp online_participants(topic), do: Presence.list(topic) 

  defp all_participants(%Server{} = server) do
    ServerParticipation.list_participants(server)
  end

end
