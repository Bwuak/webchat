defmodule WebchatWeb.ServerLive do
  use WebchatWeb, :live_view

  alias Webchat.Chat

  def mount(_params, _session, socket) do
    servers = Chat.list_servers()
    server = Enum.at(servers, 0)
    room = Chat.get_all_chatrooms |> Enum.at(0)

    IO.inspect room
    socket = assign(socket, chatroom: room)
    socket = assign(socket, servers: servers)
    socket = assign(socket, server: server) 
    {:ok, socket} 
  end

  def render(assigns) do
    ~L"""
    <div id="app">
      <%= for server <- @servers do %>
        <h1><%= server.name %></h1>
        <%= live_component @socket, ServerComponent, chatrooms: Chat.get_server_chatrooms(@server)  %>
        <%= live_component @socket, ChatroomComponent, chatroom: @chatroom %>
      <% end %>
    </div>
    """
  end


end
