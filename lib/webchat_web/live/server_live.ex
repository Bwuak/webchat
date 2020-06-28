defmodule WebchatWeb.ServerLive do
  use WebchatWeb, :live_view

  alias Webchat.Chat
  alias Webchat.Chat.Chatroom

  def mount(_params, _session, socket) do
    servers = Chat.list_servers()
    default_server = servers |> Enum.at(0)
    rooms = default_server |> Chat.get_server_chatrooms
    default_chatroom = rooms |> select_first_room

    socket = assign(socket, selected_chatroom: default_chatroom)
    socket = assign(socket, chatrooms: rooms)
    socket = assign(socket, servers: servers)
    socket = assign(socket, selected_server: hd(servers))
    {:ok, socket}
  end

  def handle_params(%{"server_id" => sid, "room_id" => rid}, _url, socket) do
    server_id = String.to_integer(sid)

    server = Chat.get_server!(server_id)
    chatrooms = Chat.get_server_chatrooms(server)

    room_id = String.to_integer(rid)
    selected_chatroom = Chat.get_chatroom(room_id)

    
    case Enum.member?(chatrooms, selected_chatroom)  do
      true ->
        socket =
          assign(socket,
            selected_server: server,
            selected_chatroom: selected_chatroom,
            chatrooms: chatrooms
          )
        {:noreply, socket}

      false ->
        {:noreply, push_patch(socket, to: "/servers", replace: true)}
    end
  end

  def handle_params(%{"server_id" => sid}, _url, socket) do
    server_id = String.to_integer(sid)

    server = Chat.get_server!(server_id)
    chatrooms = Chat.get_server_chatrooms(server)
    default_chatroom = select_first_room(chatrooms)

    socket = assign(socket,
      selected_server: server,
      chatrooms: chatrooms,
      selected_chatroom: default_chatroom
    )

    {:noreply, socket}
  end

  def handle_params(_, _, socket), do: {:noreply, socket}

  def render(assigns) do
    ~L"""
    <div id="app">
      <%= render_servers_listing(assigns) %>
      <%= render_chatrooms_listing(assigns) %>
      <%= render_chatroom(assigns) %>
    </div>
    """
  end

  defp select_first_room([]), do: %Chatroom{roomname: "NO ROOM IN THIS SERVER YET"}
  defp select_first_room([head|_tail]), do: head

  # <%= live_component @socket, ChatroomComponent, chatroom: @selected_chatroom %>
  def render_servers_listing(assigns) do
    ~L"""
    <div id="servers-listing">
      <h3>Servers</h3>
      <nav id="servers-list">
        <%= for server <- @servers do %>
          <div>
            <%= live_patch server.name,
              to: Routes.live_path(
                @socket,
                __MODULE__,
                server_id: server.id,
              ),
              class: "link",
              class: if server == @selected_server, do: "active-server link"
            %>
          </div>
        <% end %>
      </nav>
    </div>
    """
  end

  def render_chatrooms_listing(assigns) do
    ~L"""
    <div id="server" >
      <h3>Rooms</h3>
      <nav>
        <%= for room <- @chatrooms do %>
          <div>
            <%= live_patch room.roomname,
              to: Routes.live_path(
                @socket,
                __MODULE__,
                server_id: @selected_server.id,
                room_id: room.id
              ),
              class: "link",
              class: if room == @selected_chatroom, do: "active-chatroom link"
            %>
          </div>
        <% end %>
      </nav>
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
