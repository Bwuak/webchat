defmodule WebchatWeb.ServerChannel do
  use WebchatWeb, :channel

  alias Webchat.Chat
  alias Webchat.Accounts
  alias WebchatWeb.MessageView

  def join("server:" <> server_id, _params, socket) do
    send(self(), :after_join)

    {:ok, %{server_id: server_id}, assign(socket, :server_id, server_id)}
  end

  def handle_in(event, params, socket) do
    user = Accounts.get_user!(socket.assigns.user_id)
    handle_in(event, params, user, socket)
  end

  def handle_in("request_messages", params, _user, socket) do
    room = 
      params["room_id"]
      |> String.to_integer
      |> Chat.get_chatroom!

    messages = 
      room
      |> Chat.get_chatroom_messages
      |> Phoenix.View.render_many(MessageView, "message.json")

    {:reply, {:ok, %{messages: messages}}, socket} 
  end

  def handle_in("new_message", params, user, socket) do
    {:ok, room_id} = Map.fetch(params, "room_id")
    room_id = String.to_integer(room_id)

    case Chat.add_message(user, room_id, params) do
      {:ok, message} ->
        broadcast_message(socket, user, message, room_id)
        {:reply, :ok, socket}

      {:error, changeset} ->
        {:reply, {:error, %{errors: changeset}}, socket}
    end
  end

 def handle_info(:after_join, socket) do
   push(socket, "presence_state", WebchatWeb.Presence.list(socket))
   {:ok, _} = WebchatWeb.Presence.track(
     socket,
     socket.assigns.user_id,
     %{device: "broswer"}
   )
   {:noreply, socket}
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
