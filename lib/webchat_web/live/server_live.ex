defmodule WebchatWeb.ServerLive do
  use WebchatWeb, :live_view

  alias Webchat.Chat

  def mount(_params, _session, socket) do
    servers = Chat.list_servers()
    socket = assign(socket, servers: servers)
    {:ok, socket} 
  end

  def render(assigns) do
    ~L"""
    <%= for server <- @servers do %>
      <h1><%= server.name %></h1>
      <%= live_patch link_body(server),
        to: Routes.live_path(
          @socket
    <% end %>
    """
  end


end
