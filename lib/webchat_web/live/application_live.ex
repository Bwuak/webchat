defmodule WebchatWeb.ApplicationLive do
  use WebchatWeb, :live_view

  alias Webchat.Chat
  alias Webchat.Chat.Chatroom
  alias WebchatWeb.Chat.ChatroomComponent

  def mount(_session, socket) do
    IO.inspect socket 
    socket = 
      socket
      |> put_servers()
      |> put_default_server()
      |> put_chatrooms()
      |> put_default_chatroom()
    IO.inspect socket
    {:ok, socket}
  end

  def mount(_params, _session, socket) do
    socket = 
      socket
      |> put_servers()
      |> put_default_server()
      |> put_chatrooms()
      |> put_default_chatroom()
    IO.inspect socket
    {:ok, socket}
  end
  def handle_params(_,socket) do
    IO.puts "hello"
    socket =
      socket
      |> put_servers
      |> put_default_server
      |> put_chatrooms
      |> put_default_chatroom


    IO.inspect socket
    {:noreply, socket}
  end

  def handle_params(%{"server_id" => sid, "room_id" => rid}, _url, socket) do
    server_id = String.to_integer(sid)
    room_id = String.to_integer(rid)

    socket =
      socket
      |> put_selected_server(server_id)
      |> put_chatrooms
      |> put_selected_chatroom(room_id)

    case Enum.member?(socket.assigns.chatrooms, socket.assigns.selected_chatroom)  do
      true ->
        {:noreply, socket}

      false ->
        {:noreply, push_patch(socket, to: "/servers", replace: true)}
    end
  end

    def handle_params(%{"server_id" => sid}, _url, socket) do
    server_id = String.to_integer(sid)

    socket = 
      socket
      |> put_selected_server(server_id)
      |> put_chatrooms
      |> put_default_chatroom

    {:noreply, socket}
  end

  def handle_params(_, _, socket) do
    socket = 
      socket
      |> put_servers
      |> put_default_server
      |> put_chatrooms
      |> put_default_chatroom

    {:noreply, socket}
  end

  def render(assigns) do
    ~L"""
    <div id="app">
      <%= render_servers_listing(assigns) %>
      <%= render_chatrooms_listing(assigns) %>
      <%= live_component @socket, ChatroomComponent, selected_chatroom: @selected_chatroom %>
      <div>
        <h3>Users</h3>
        <div id="online-users-list">
        </div>
      </div>
    </div>
    """
  end
      
  defp put_servers(socket) do
    servers = Chat.list_servers()
    assign(socket, servers: servers)
  end

  defp put_default_server(socket) do
    default_server = 
      socket.assigns.servers
      |> Enum.at(0)

    assign(socket, selected_server: default_server)
  end

  defp put_selected_server(socket, server_id) when is_integer(server_id) do
    server = Chat.get_server!(server_id)
    assign(socket, selected_server: server) 
  end

  defp put_chatrooms(socket) do
    chatrooms =
      socket.assigns.selected_server
      |> Chat.get_server_chatrooms

   assign(socket, chatrooms: chatrooms) 
  end

  defp put_default_chatroom(socket) do
    selected_chatroom =
      socket.assigns.chatrooms
      |> select_first_room

    assign(socket, selected_chatroom: selected_chatroom)
  end

  defp put_selected_chatroom(socket, room_id) when is_integer(room_id) do
    room = Chat.get_chatroom!(room_id)
    assign(socket, selected_chatroom: room)
  end


  defp select_first_room([]), do: %Chatroom{roomname: "NO ROOM IN THIS SERVER YET"}
  defp select_first_room([head|_tail]), do: head

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
                server_id: server.id
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

end
