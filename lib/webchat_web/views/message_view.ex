defmodule WebchatWeb.MessageView do
  use WebchatWeb, :view

  def render("message.json", %{message: message}) do
    %{
      id: message.id,
      at: message.at,
      content: message.content,
      user: render_one(message.user, WebchatWeb.UserView, "user.json")
    }
  end
end
