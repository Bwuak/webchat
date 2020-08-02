defmodule WebchatWeb.ChatLive do
  use WebchatWeb, :live_view

  alias Webchat.Accounts
  alias Webchat.Chat
  alias WebchatWeb.Chat.ServerActionComponent
  alias WebchatWeb.Chat.ServerCreationComponent
  alias WebchatWeb.Chat.ServerSubscriptionComponent
  alias WebchatWeb.Chat.RoomCreationComponent


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
      selected_chatroom: Chat.select_first_room(chatrooms) 
    )}
  end

  def handle_params(_, _, socket) do
    default_server = Chat.select_default_server(socket.assigns.servers)
    chatrooms = Chat.select_chatrooms(default_server)

    {:noreply, assign(socket,
      selected_server: default_server,
      chatrooms: chatrooms,
      selected_chatroom: Chat.select_first_room(chatrooms)
    )}
  end

  def render(assigns) do
    ~L"""
    <%= if Map.has_key?(assigns, :action) do %>
      <div class="action">
        <div class="page-container">
          <%= live_component @socket, action_component(assigns), Map.put(assigns, :id, "action")  %>
        </div>
      </div>
    <% end %>
    """
  end

  # Removing component 
  def handle_event("cancel-action", _, socket) do
    socket_without_action = 
      %{ socket |
        assigns: Map.delete(socket.assigns, :action), 
        changed: Map.put_new(socket.changed, :action, true) } 
    {:noreply, socket_without_action} 
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

  # Conditional component
  def action_component(%{action: action} = _assigns) do
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
