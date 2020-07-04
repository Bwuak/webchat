defmodule WebchatWeb.Chat.ChatroomComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    WebchatWeb.ChatroomView.render("show.html", assigns)
  end

end
