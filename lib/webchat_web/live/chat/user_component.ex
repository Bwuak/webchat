defmodule WebchatWeb.Chat.UserComponent do
  use Phoenix.LiveComponent

  alias WebchatWeb.Router.Helpers, as: Routes


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
