defmodule WebchatWeb.ChatController do
  use WebchatWeb, :controller

  alias Webchat.Chat

  plug :authenticate_user when action in [:index, :show]

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def show(conn, %{"id" => chatroom_id}) do
    user = conn.assigns.current_user
    changeset = Chat.change_message(%Chat.Message{})
    room = Chat.get_chatroom!(chatroom_id)
    render(conn, "show.html", changeset: changeset, chatroom: room)
  end

end
