defmodule WebchatWeb.ChatroomChannel do
  use WebchatWeb, :channel

  alias Webchat.Chat.Chatrooms
  alias Webchat.Administration.Users

  alias Webchat.Chat.Messages
  alias WebchatWeb.MessageView

  def join("room:" <> room_id, _params, socket) do
    room_id = String.to_integer(room_id)
    room = Chatrooms.get_chatroom(room_id)

    messages = 
      room
      |> Messages.get_chatroom_messages 
      |> Phoenix.View.render_many(MessageView, "message.json")

    {:ok, %{messages: messages}, assign(socket, :room_id, room_id)}
  end

  def handle_in(event, params, socket) do
    user = Users.get!(socket.assigns.user_id)
    handle_in(event, params, user, socket)
  end

  def handle_in("new_message", params, user, socket) do
    room_id = socket.assigns.room_id

    case Messages.add_message(user, room_id, params) do
      {:ok, message} ->
        broadcast_message(socket, user, message, room_id)
        {:reply, :ok, socket}

      {:error, changeset} ->
        {:reply, {:error, %{errors: changeset}}, socket}
    end
  end

  defp broadcast_message(socket, user, message, room_id) do
    broadcast!(socket, "new_message", %{
      message: MessageView.render("message.json", %{
        user: user,
        message: message,
        room_id: room_id
      })
    })
  end


end
