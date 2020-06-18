defmodule WebchatWeb.ChatroomChannel do
  use WebchatWeb, :channel

  alias Webchat.Chat
  alias Webchat.Accounts
  alias WebchatWeb.MessageView

  def join("room:" <> room_id, params, socket) do
    send(self(), :after_join)
    last_seen_id = params["last_seen_id"] || 0
    room_id = String.to_integer(room_id)
    room = Chat.get_chatroom(room_id)

    messages = 
      room
      |> Chat.get_chatroom_messages 
      |> Phoenix.View.render_many(WebchatWeb.MessageView, "message.json")

    {:ok, %{messages: messages}, assign(socket, :room_id, room_id)}
  end

  def handle_in(event, params, socket) do
    user = Accounts.get_user!(socket.assigns.user_id)
    handle_in(event, params, user, socket)
  end

  def handle_in("new_message", params, user, socket) do
    {:reply, :ok, socket}
  end

  def hanlde_info(:after_join, socket) do

  end

end
