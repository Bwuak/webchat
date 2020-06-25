defmodule WebchatWeb.ServerLive do
  use WebchatWeb, :live_view

  alias Webchat.Chat

  def mount(_params, _session, socket) do
    servers = Chat.list_servers()
    server = Enum.at(servers, 0)

    socket = assign(socket, servers: servers)
    socket = assign(socket, server: server) 
    {:ok, socket} 
  end

  def render(assigns) do
    ~L"""
    <div>
      <%= for server <- @servers do %>
        <h1><%= server.name %></h1>
        <%= live_component @socket, ServerComponent, chatrooms: Chat.get_server_chatrooms(@server)  %>
      <% end %>
    </div>
    """
  end


end
