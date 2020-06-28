defmodule WebchatWeb.MessageView do
  use WebchatWeb, :view

  def render("message.json", %{message: message, user: user, room_id: room_id}) do
    %{
      id: message.id,
      content: message.content,
      at: message.inserted_at,
      user: render_one(user, WebchatWeb.UserView, "user.json"),
      room_id: room_id
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
