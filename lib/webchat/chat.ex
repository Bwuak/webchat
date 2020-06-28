defmodule Webchat.Chat do
  import Ecto.Query, warn: false

  alias Webchat.Repo
  alias Webchat.Accounts
  alias Webchat.Chat.Chatroom
  alias Webchat.Chat.Message
  alias Webchat.Chat.Server


  def create_chatroom(server_id, attrs \\ %{}) do
    %Chatroom{server_id: server_id}
    |> Chatroom.changeset(attrs)
    |> Repo.insert()
  end

  def get_all_chatrooms() do
    Chatroom
    |> Repo.all
  end

  def get_chatroom_messages(%Chatroom{id: chatroom_id}) do
    Message
    |> chatroom_messages_query(chatroom_id)
    |> Repo.all()  
  end

  def get_chatroom!(chatroom_id), do: Repo.get!(Chatroom, chatroom_id)
  def get_chatroom(chatroom_id), do: Repo.get(Chatroom, chatroom_id)

  def change_chatroom(%Chatroom{} = chatroom, attrs \\ %{}) do
    Chatroom.changeset(chatroom, attrs)
  end

  def change_message(%Message{} = message, attrs \\ %{}) do
    Message.changeset(message, attrs)
  end

  def add_message(%Accounts.User{id: user_id}, chatroom_id, attrs) do
    %Message{user_id: user_id, chatroom_id: chatroom_id}
    |> Message.changeset(attrs)
    |> Repo.insert()
  end

  defp chatroom_messages_query(query, chatroom_id) do
    from( v in query, 
      where: v.chatroom_id == ^chatroom_id,
      preload: [:user]
    )
  end

  def get_server_chatrooms(%Server{} = server) do
    Chatroom
    |> server_chatrooms_query(server)
    |> Repo.all()
  end

  def server_chatrooms_query(query, %Server{id: server_id}) do
    from( c in query,
      where: c.server_id == ^server_id
    )
  end

  def list_servers do
    Repo.all(Server)
  end

  def get_server!(id), do: Repo.get!(Server, id)

  def create_server(attrs \\ %{}) do
    %Server{}
    |> Server.changeset(attrs)
    |> Repo.insert()
  end

  def update_server(%Server{} = server, attrs) do
    server
    |> Server.changeset(attrs)
    |> Repo.update()
  end

  def delete_server(%Server{} = server) do
    Repo.delete(server)
  end

  def change_server(%Server{} = server, attrs \\ %{}) do
    Server.changeset(server, attrs)
  end
end
