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
  alias Webchat.Chat.Servers
  alias Webchat.Chat.Participants
  alias Webchat.Administration.Users

  @topic "server:"

  def render(assigns) do
    ~L"""
    <!-- Layout <- chat_live <- components " -->

    <!-- conditional rendering of live components -->
    <%= if Map.has_key?(assigns, :action) do %>
      <div class="action">
        <%= live_component @socket, action_component(assigns), Map.put(assigns, :id, "action" )  %>
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
    selected_server = String.to_integer(sid) |> Servers.get!()
    chatrooms = Chat.select_chatrooms(selected_server) 
    selected_chatroom = String.to_integer(rid) |> Chat.Chatrooms.get_chatroom!()

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
    selected_server = String.to_integer(sid) |> Servers.get!()
    chatrooms = Chat.select_chatrooms(selected_server) 

    socket = subscribe_to_server(selected_server, socket)
    {:noreply, assign(socket,
      selected_server: selected_server,
      chatrooms: chatrooms,
      selected_chatroom: Chat.select_default_chatroom(chatrooms) 
    )}
  end

  def handle_params(_, _, socket) do
    default_server = Chat.select_default_server(socket.assigns.servers)
    chatrooms = Chat.select_chatrooms(default_server)

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
    {:noreply, assign(socket, action: "server_action") }
  end

  def handle_event("create-server", _, socket) do
    {:noreply, assign(socket, action: "create_server") }
  end

  def handle_event("join-server", _, socket) do
    {:noreply, assign(socket, action: "join_server") }
  end

  def handle_event("create-room", _, socket) do
    {:noreply, assign(socket, action: "create_chatroom") }
  end

  # Handle errors
  def handle_info({_AnyComponent, :error, msg}, socket) do
    {:noreply, assign(socket, 
      action: "error",
      error: msg
    ) }
  end

  # Presence tracking changes callback
  def handle_info(%Phoenix.Socket.Broadcast{} = broadcast, socket) do
    {:noreply, assign(socket, 
      users: subscribed_server_userlist(broadcast.topic) 
    ) }
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
    new_socket = remove_socket_action(socket)

    {:noreply, push_patch(new_socket,
      to: Routes.live_path(new_socket, __MODULE__, 
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

  # Conditional component
  defp action_component(%{action: action} = _assigns) do
    case action do
      "server_action" ->
        ServerActionComponent
      "create_server" ->
        ServerCreationComponent 
      "join_server" ->
        ServerSubscriptionComponent
      "create_chatroom" ->
        ChatroomCreationComponent
      "error" ->
        ErrorComponent
    end
  end

  defp subscribe_to_server(%Server{} = server, socket) do
    socket = unsubscribe_to_server(socket.assigns.subscription, socket)
    case server.id do
      nil ->
        socket
      id ->
        topic = @topic <> Integer.to_string(id)
        WebchatWeb.Endpoint.subscribe(topic)
        assign(socket, 
          subscription: topic,
          users: subscribed_server_userlist(topic)
        ) 
    end
  end

  defp unsubscribe_to_server(nil, socket), do: socket 
  defp unsubscribe_to_server(topic, socket) do
    WebchatWeb.Endpoint.unsubscribe(topic)
    assign(socket, subscription: nil)
  end

  # Only temporary, will remove unecessary elements
  defp subscribed_server_userlist(topic) do
    topic
    |> WebchatWeb.Presence.list()
    |> Enum.map(&(elem(&1, 1).user))
  end

end
