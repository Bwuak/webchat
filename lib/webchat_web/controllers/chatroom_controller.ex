defmodule WebchatWeb.ChatroomController do
  use WebchatWeb, :controller

  alias Webchat.Chat

  plug :authenticate_user 


  def new(conn, _params) do
    changeset = Chat.change_chatroom(%Chat.Chatroom{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"chatroom" => chatroom_params}) do
    case Chat.create_chatroom(chatroom_params) do
      {:ok, _chatroom} ->
        conn
        |> put_flash(:info, "Room created successfully.")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end


end
