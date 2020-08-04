defmodule WebchatWeb.ChatLive do
  use WebchatWeb, :live_view

  alias Webchat.Accounts
  alias Webchat.Chat
  alias WebchatWeb.Chat.ServerActionComponent
  alias WebchatWeb.Chat.ServerCreationComponent
  alias WebchatWeb.Chat.ServerSubscriptionComponent
  alias WebchatWeb.Chat.RoomCreationComponent


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
    user = Accounts.get_user!(session["user_id"])
    servers = Chat.list_servers()

    {:ok, 
      assign(socket, 
        servers: servers,
        user: user),
      layout: {WebchatWeb.LayoutView, "chat_live.html"}
    }
  end

  def handle_params(%{"server_id" => sid, "room_id" => rid}, _url, socket) do
    selected_server = String.to_integer(sid) |> Chat.get_server!()
    chatrooms = Chat.select_chatrooms(selected_server) 
    selected_chatroom = String.to_integer(rid) |> Chat.get_chatroom!()

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
    selected_server = String.to_integer(sid) |> Chat.get_server()
    chatrooms = Chat.select_chatrooms(selected_server) 

    {:noreply, assign(socket,
      selected_server: selected_server,
      chatrooms: chatrooms,
      selected_chatroom: Chat.select_default_room(chatrooms) 
    )}
  end

  def handle_params(_, _, socket) do
    default_server = Chat.select_default_server(socket.assigns.servers)
    chatrooms = Chat.select_chatrooms(default_server)

    {:noreply, assign(socket,
      selected_server: default_server,
      chatrooms: chatrooms,
      selected_chatroom: Chat.select_default_room(chatrooms)
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

  def handle_info({ServerCreationComponent, :server_created, new_server}, socket) do
    new_socket = 
      socket
      |> remove_socket_action()
      |> update_socket_servers(new_server)
    {:noreply, push_patch(new_socket, 
      to: Routes.live_path(new_socket, __MODULE__, server_id: new_server.id),
      replace: true
    ) } 
  end

  defp update_socket_servers(socket, new_server) do
    %{ socket |
      assigns: put_in(socket.assigns.servers, new_server),
      changed: Map.put_new(socket.changed, :servers, true)
    }
  end

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
        RoomCreationComponent
    end
  end

end
