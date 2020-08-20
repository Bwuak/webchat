defmodule WebchatWeb.ChatLive do
  use WebchatWeb, :live_view
  import WebchatWeb.Subscriptions.Server

  # Components
  alias WebchatWeb.Chat.ServerActionComponent
  alias WebchatWeb.Chat.ServerCreationComponent
  alias WebchatWeb.Chat.ServerSubscriptionComponent
  alias WebchatWeb.Chat.Models.ChatroomCreationComponent
  alias WebchatWeb.Chat.ServerSubscriptionComponent
  alias WebchatWeb.Chat.ErrorComponent

  # Domain dependencies
  alias Webchat.Chat
  alias Webchat.Chat.ServerParticipation
  alias Webchat.Administration.Users


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
    servers = ServerParticipation.list_servers(user)

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
    selected_server = Chat.select_server(sid)
    selected_chatroom = Chat.select_chatroom(selected_server, rid)

    socket = subscribe_to_server(selected_server, socket)
    case selected_chatroom do 
      nil ->
        {:noreply, push_patch(socket, to: "/chat", replace: true)}
      _ ->
        {:noreply, assign(socket,
          selected_server: selected_server,
          chatrooms: selected_server.chatrooms, 
          selected_chatroom: selected_chatroom 
          )}
    end
  end

  def handle_params(%{"server_id" => sid}, _url, socket) do
    selected_server = Chat.select_server(sid)
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

  # Error component 
  def handle_info({_AnyComponent, :error, msg}, socket) do
    {:noreply, assign(socket, 
      action: ErrorComponent,
      error: msg
    ) }
  end

  # Presence tracking changes callback
  def handle_info(%Phoenix.Socket.Broadcast{} = _broadcast, socket) do
    # We are fetching the full presence list
    # Could become a bottleneck
    {:noreply, assign(socket, 
      users: participants_list(socket.assigns.selected_server) 
    )}
  end

  # server creation callback
  def handle_info({ServerCreationComponent, :server_created, new_server}, socket) do
    socket = 
      socket
      |> remove_socket_action()
      |> assign(servers: ServerParticipation.list_servers(socket.assigns.user) )

    {:noreply, push_patch(socket, 
      to: Routes.live_path(socket, __MODULE__, server_id: new_server.id),
      replace: true
    ) } 
  end

  # chatroom creation callback
  def handle_info({ChatroomCreationComponent, :chatroom_created, new_chatroom}, socket) do
    socket = 
      socket
      |> remove_socket_action()

    {:noreply, push_patch(socket,
      to: Routes.live_path(socket, __MODULE__, 
        %{server_id: socket.assigns.selected_server.id,
          room_id: new_chatroom.id}),
        replace: true
    )}
  end

  def handle_info({ServerSubscriptionComponent, :server_joined, server_joined}, socket) do
    socket = 
      socket
      |> remove_socket_action()
      |> assign(servers: ServerParticipation.list_servers(socket.assigns.user) )

    {:noreply, push_patch(socket,
      to: Routes.live_path(socket, __MODULE__, server_id: server_joined.id),
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

end
