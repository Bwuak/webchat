defmodule WebchatWeb.ChatLive do
  use WebchatWeb, :live_view

  alias WebchatWeb.Chat.ServerActionComponent
  alias WebchatWeb.Chat.ServerCreationComponent
  alias WebchatWeb.Chat.ServerSubscriptionComponent
  alias WebchatWeb.Chat.Models.ChatroomCreationComponent
  alias WebchatWeb.Chat.ServerSubscriptionComponent
  alias WebchatWeb.Chat.ErrorComponent

  alias Webchat.Chat.Models.Server
  alias Webchat.Chat
  alias Webchat.Chat.Chatrooms
  alias Webchat.Chat.Participants
  alias Webchat.Administration.Users

  @topic_prefix "server:"

  def render(assigns) do
    ~L"""
    <!-- Layout <- chat_live <- components " -->

    <!-- conditional rendering of live components -->
    <%= if Map.has_key?(assigns, :action) do %>
      <div class="action">
        <%= live_component @socket, assigns.action, Map.put(assigns, :id, "action" )  %>
      </div>
    <% end %>
    """
  end

  def mount(_params, session, socket) do
    user = Users.get!(session["user_id"])
    servers = Participants.list_servers(user)

    {:ok, 
      assign(socket, 
        servers: servers,
        user: user,
        users: [],
        subscription: nil),
      layout: {WebchatWeb.LayoutView, "chat_live.html"}
    }
  end

  def handle_params(%{"server_id" => sid, "room_id" => rid}, _url, socket) do
    selected_server = Chat.select_server_by_id(sid)
    chatrooms = selected_server.chatrooms 
    selected_chatroom = Chatrooms.get_chatroom!(rid)

    socket = subscribe_to_server(selected_server, socket)
    case Enum.member?(chatrooms, selected_chatroom)  do
      true ->
        {:noreply, assign(socket,
          selected_server: selected_server,
          chatrooms: chatrooms,
          selected_chatroom: selected_chatroom 
          )}

      false ->
        {:noreply, push_patch(socket, to: "/chat", replace: true)}
    end
  end

  def handle_params(%{"server_id" => sid}, _url, socket) do
    selected_server = Chat.select_server_by_id(sid)
    chatrooms = selected_server.chatrooms 

    socket = subscribe_to_server(selected_server, socket)
    {:noreply, assign(socket,
      selected_server: selected_server,
      chatrooms: chatrooms,
      selected_chatroom: Chat.select_default_chatroom(chatrooms) 
    )}
  end

  def handle_params(_, _, socket) do
    default_server = Chat.select_default_server(socket.assigns.servers)
    chatrooms = default_server.chatrooms 

    socket = subscribe_to_server(default_server, socket)
    {:noreply, assign(socket,
      selected_server: default_server,
      chatrooms: chatrooms,
      selected_chatroom: Chat.select_default_chatroom(chatrooms)
    )}
  end

  # Removing component 
  def handle_event("cancel-action", _, socket) do
    new_socket = remove_socket_action(socket)
    {:noreply, new_socket} 
  end

  # Adding component
  def handle_event("server-action", _, socket) do
    {:noreply, assign(socket, action: ServerActionComponent) }
  end

  def handle_event("create-server", _, socket) do
    {:noreply, assign(socket, action: ServerCreationComponent) }
  end

  def handle_event("join-server", _, socket) do
    {:noreply, assign(socket, action: ServerSubscriptionComponent) }
  end

  def handle_event("create-room", _, socket) do
    {:noreply, assign(socket, action: ChatroomCreationComponent) }
  end

  # Handle errors
  def handle_info({_AnyComponent, :error, msg}, socket) do
    {:noreply, assign(socket, 
      action: ErrorComponent,
      error: msg
    ) }
  end

  # Presence tracking changes callback
  def handle_info(%Phoenix.Socket.Broadcast{} = _broadcast, socket) do
    # not using broadcast
    # We are fetching the full presence list
    # Could become a bottleneck
    {:noreply, assign(socket, 
      users: participants_list(socket.assigns.selected_server) 
    )}
  end
   

  # server creation callback
  def handle_info({ServerCreationComponent, :server_created, new_server}, socket) do
    new_socket = 
      socket
      |> remove_socket_action()
      |> assign(servers: Participants.list_servers(socket.assigns.user) )

    {:noreply, push_patch(new_socket, 
      to: Routes.live_path(new_socket, __MODULE__, server_id: new_server.id),
      replace: true
    ) } 
  end

  # chatroom creation callback
  def handle_info({ChatroomCreationComponent, :chatroom_created, new_chatroom}, socket) do
    socket = 
      socket
      |> remove_socket_action()
      |> assign(:selected_chatroom, new_chatroom)

    {:noreply, push_patch(socket,
      to: Routes.live_path(socket, __MODULE__, 
        %{server_id: socket.assigns.selected_server.id,
          room_id: new_chatroom.id}),
        replace: true
    )}
  end

  def handle_info({ServerSubscriptionComponent, :server_joined, server_joined}, socket) do
    new_socket = 
      socket
      |> remove_socket_action()
      |> assign(servers: Participants.list_servers(socket.assigns.user) ) 

    {:noreply, push_patch(new_socket,
      to: Routes.live_path(new_socket, __MODULE__, server_id: server_joined.id),
      replace: true
    ) }
  end

  def handle_infO(_, _), do: nil

  # removing conditional component
  defp remove_socket_action(socket) do
    %{ socket |
      assigns: Map.delete(socket.assigns, :action), 
      changed: Map.put_new(socket.changed, :action, true)
    }
  end

  defp subscribe_to_server(server, socket) when is_nil(server), do: socket 
  defp subscribe_to_server(%Server{} = server, socket) do
    socket = unsubscribe_to_server(socket.assigns.subscription, socket)
    case server.id do
      nil ->
        socket
      id ->
        topic = topic(id) 
        WebchatWeb.Endpoint.subscribe(topic)
        assign(socket, 
          subscription: topic,
          users: participants_list(server)
        ) 
    end
  end

  defp unsubscribe_to_server(nil, socket), do: socket 
  defp unsubscribe_to_server(topic, socket) do
    WebchatWeb.Endpoint.unsubscribe(topic)
    assign(socket, subscription: nil)
  end

  defp topic(serverId) when is_integer(serverId) do
    @topic_prefix <> Integer.to_string(serverId)
  end
  defp topic(serverId), do: @topic_prefix <> serverId

  defp participants_list(%Server{} = server) do
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
    |> Enum.sort_by( &( String.at(&1.username, 0) ))
    |> Enum.reverse()
    |> Enum.sort_by( &(&1.status) ) 
    |> Enum.reverse()
    # I really hope there's a better way to sort this
  end

  defp online_participants(topic), do: WebchatWeb.Presence.list(topic) 

  defp all_participants(%Server{} = server) do
    Participants.list_participants(server)
  end

end
