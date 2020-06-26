defmodule WebchatWeb.ServerLive do
  use WebchatWeb, :live_view

  alias Webchat.Chat

  def mount(_params, _session, socket) do
    servers = Chat.list_servers()
    room = Chat.get_all_chatrooms |> Enum.at(0)

    socket = assign(socket, selected_chatroom: room)
    socket = assign(socket, chatrooms: Chat.get_all_chatrooms)
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
      <%= servers(assigns) %>
      <div id="server" >
      <%= for room <- @chatrooms do %>
        <%= live_patch room.roomname,
            to: Routes.live_path(
              @socket,
              __MODULE__,
              server_id: @selected_server.id,
              room_id: room.id
            )
          %>
      <% end %>
    </div>

      <%= if @selected_chatroom != nil do %>
        <%= render_chatroom(assigns) %>
      <% end %>
    </div>
    """
  end

  defp select_first_room([]), do: nil
  defp select_first_room([head|tai]), do: head

  # <%= live_component @socket, ChatroomComponent, chatroom: @selected_chatroom %>
  def servers(assigns) do
    ~L"""
      <nav id="servers-list">
        <%= for server <- @servers do %>
          <div>
          <%= live_patch server.name,
            to: Routes.live_path(
              @socket,
              __MODULE__,
              server_id: server.id,
            )
          %>
          </div>
        <% end %>
      </nav>
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
              server_id: @selected_server.id,
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
