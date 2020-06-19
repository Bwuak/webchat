defmodule WebchatWeb.ChatroomChannel do
  use WebchatWeb, :channel

  alias Webchat.Chat
  alias Webchat.Accounts
  alias WebchatWeb.MessageView

  def join("room:" <> room_id, params, socket) do
    send(self(), :after_join)
    _last_seen_id = params["last_seen_id"] || 0
    room_id = String.to_integer(room_id)
    room = Chat.get_chatroom(room_id)

    messages = 
      room
      |> Chat.get_chatroom_messages 
      |> Phoenix.View.render_many(MessageView, "message.json")

    {:ok, %{messages: messages}, assign(socket, :room_id, room_id)}
  end

  def handle_in(event, params, socket) do
    user = Accounts.get_user!(socket.assigns.user_id)
    handle_in(event, params, user, socket)
  end

  def handle_in("new_message", params, user, socket) do
    room_id = socket.assigns.room_id

    case Chat.add_message(user, room_id, params) do
      {:ok, message} ->
        broadcast_message(socket, user, message)
        {:reply, :ok, socket}

      {:error, changeset} ->
        {:reply, {:error, %{errors: changeset}}, socket}
    end
  end

  def hanlde_info(:after_join, socket) do
    push(socket, "presence_state", WechatWeb.Presence.list(socket))
    {:ok, _} = WebchatWeb.Presence.track(
      socket,
      socket.assigns.user_id,
      %{device: "browser"}
    )

    {:noreply, socket}
  end

  defp broadcast_message(socket, user, message) do
    broadcast!(socket, "new_message", %{
      message: MessageView.render("message.json", %{user: user, message: message})
        }
      )
  end


end
