defmodule WebchatWeb.Chat.ServerListingComponent do
  use Phoenix.LiveComponent

  alias WebchatWeb.Router.Helpers, as: Routes


  def render(assigns) do
    ~L"""
    <div id="servers-listing">
      <h3>Servers</h3>
      <nav id="servers-list">
        <%= for server <- @servers do %>
          <div>
            <%= live_patch server.name,
              to: Routes.live_path(
                @socket,
                WebchatWeb.ChatLive,
                server_id: server.id
              ),
              class: "server-link",
              class: if server == @selected_server, do: "active-server server-link"
            %>
          </div>
        <% end %>
        <div><div phx-click="server-action" class="server-link" phx-click="hello">Add or Join</div></div>
      </nav>
    </div>
    """
  end

end
