defmodule WebchatWeb.Chat.UserListComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
      <div id="users-listing" >
        <h3>Users</h3>
        <div id="online-users-list">
        <%= for user <- @users do %>
          <p class="<%= user.status %>" ><%= user.username %></p>
        <% end %>
        </div>
      </div>
    """
  end

  def update(assigns, socket) do
    {:ok, assign(socket, users: assigns.users) }
  end

end
