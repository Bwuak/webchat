defmodule WebchatWeb.Chat.UserComponent do
  use Phoenix.LiveComponent


  def render(assigns) do
    ~L"""
      <div id="user">
        <p><%= @user.username  %></p>
        <div id="link-container" phx-update="ignore">
        </div>
      </div>
    """
  end

end
