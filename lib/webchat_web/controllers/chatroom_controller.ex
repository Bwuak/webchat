defmodule WebchatWeb.ChatroomController do
  use WebchatWeb, :controller
  plug :authenticate_user 


  alias Webchat.Chat.Models.Chatroom
  alias Webchat.Chat.Chatrooms


  def new(conn, _params) do
    changeset = Chatrooms.change_chatroom(%Chatroom{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"chatroom" => chatroom_params}) do
    case Chatrooms.create_chatroom(chatroom_params) do
      {:ok, _chatroom} ->
        conn
        |> put_flash(:info, "Room created successfully.")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end


end
