defmodule WebchatWeb.ServerLive do
  use WebchatWeb, :live_view

  alias Webchat.Chat

  def mount(_params, _session, socket) do
    servers = Chat.list_servers()
    server = Enum.at(servers, 0)
    room = Chat.get_all_chatrooms |> Enum.at(0)

    socket = assign(socket, selected_chatroom: room)
    socket = assign(socket, chatrooms: Chat.get_all_chatrooms)
    socket = assign(socket, servers: servers)
    socket = assign(socket, selected_server: hd(servers)) 
    {:ok, socket} 
  end

  def handle_params(%{"server_id" => sid, "room_id" => rid}, _url, socket) do
    server_id = String.to_integer(sid)
    room_id = String.to_integer(rid)

    room = Chat.get_chatroom(room_id)
    server = Chat.get_server!(server_id)
    chatrooms = Chat.get_server_chatrooms(server)

    socket =
      assign(socket,
        selected_server: server,
        selected_chatroom: room,
        chatrooms: chatrooms,
      )

    {:noreply, socket}
  end

  def handle_params(_, _, socket), do: {:noreply, socket}

  def render(assigns) do
    ~L"""
    <div id="app">
      <%= servers(assigns) %>
      <%= server_chatrooms(assigns) %>
      <%= render_chatroom(assigns) %>
    </div>
    """
  end
  # <%= live_component @socket, ChatroomComponent, chatroom: @selected_chatroom %>
  def servers(assigns) do
    ~L"""
      <div id="servers-list">
        <%= for server <- @servers do %>
          <%= live_patch server.name,
            to: Routes.live_path(
              @socket,
              __MODULE__,
              server_id: server.id
            )
          %>
        <% end %>
      </div>
    """

  end

  def server_chatrooms(assigns) do
    ~L"""
    <div id="server" >
      <%= for room <- @chatrooms do %>
        <%= live_patch room.roomname,
            to: Routes.live_path(
              @socket,
              __MODULE__,
              room_id: room.id
            )
          %>
      <% end %>
    </div>
    """
  end

  def render_chatroom(assigns) do
    ~L"""
    <div
      id="chatroom" data-id="<%= @selected_chatroom.id %>"
    >
      <div id="name-container">
        <h1 id="chatroom-name"><%= @selected_chatroom.roomname %></h1>
      </div>
      <div id="messages-container">
      </div>
      <div id="chatbox">
        <div id="msg-box">
          <textarea 
             autofocus
             id="msg-input"
             placeholder="Message..."
          ></textarea>
          <button id="msg-submit">
            Send
          </button>
        </div>
      </div>
    </div>
    """
  end

end
