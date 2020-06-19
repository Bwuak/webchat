defmodule WebchatWeb.ChatroomController do
  use WebchatWeb, :controller

  alias Webchat.Chat

  plug :authenticate_user 

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def show(conn, %{"id" => chatroom_id}) do
    room = Chat.get_chatroom!(chatroom_id)
    render(conn, "show.html", chatroom: room)
  end

  def new(conn, _params) do
    changeset = Chat.change_chatroom(%Chat.Chatroom{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"chatroom" => chatroom_params}) do
    IO.inspect chatroom_params
    case Chat.create_chatroom(chatroom_params) do
      {:ok, chatroom} ->
        conn
        |> put_flash(:info, "Room created successfully.")
        |> redirect(to: Routes.chatroom_path(conn, :show, chatroom.id))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end


end
