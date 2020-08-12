defmodule WebchatWeb.ServerChannel do
  use WebchatWeb, :channel

  alias Webchat.Administration.Users

  alias Webchat.Chat.Messages
  alias Webchat.Chat.Chatrooms
  alias WebchatWeb.MessageView



  def join("server:" <> server_id, _params, socket) do
    send(self(), :after_join)

    {:ok, %{server_id: server_id}, assign(socket, :server_id, server_id)}
  end

  def handle_in(event, params, socket) do
    user = Users.get!(socket.assigns.user_id)
    handle_in(event, params, user, socket)
  end

  @very_high_number 90000000
  def handle_in("request_messages", 
    %{"room_id" => id, "oldest" => oldest}, _user, socket) when id > 0 do

    oldest_id = if oldest != "nil", do: oldest, else: @very_high_number
    messages = 
      id
      |> Chatrooms.get_chatroom!
      |> Messages.get_chatroom_old_messages(oldest_id)
      |> Phoenix.View.render_many(MessageView, "message.json")

    {:reply, {:ok, %{messages: messages, room_id: id}}, socket} 
  end

  def handle_in("new_message", params, user, socket) do
    IO.puts "hey"
    {:ok, room_id} = Map.fetch(params, "room_id")

    case Messages.add_message(user, room_id, params) do
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
