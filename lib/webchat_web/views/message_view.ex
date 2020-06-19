defmodule WebchatWeb.MessageView do
  use WebchatWeb, :view

  def render("message.json", %{message: message, user: user}) do
    %{
      id: message.id,
      content: message.content,
      at: message.inserted_at,
      user: render_one(user, WebchatWeb.UserView, "user.json")
    }
  end

  def render("message.json", %{message: message}) do
    %{
      id: message.id,
      content: message.content,
      at: message.inserted_at,
      user: render_one(message.user, WebchatWeb.UserView, "user.json")
    }
  end

end
