defmodule WebchatWeb.Chat.UserListComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
      <div id="users-listing" phx-update="ignore">
        <h3>Users</h3>
        <div id="online-users-list">
        </div>
      </div>
    """
  end

end
