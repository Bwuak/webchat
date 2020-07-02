defmodule WebchatWeb.Chat.UserListComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
      <div>
        <h3>Users</h3>
        <div id="online-users-list">
        </div>
      </div>
    """
  end

end
