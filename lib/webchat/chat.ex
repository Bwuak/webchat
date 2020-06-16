defmodule Webchat.Chat do
  import Ecto.Query, warn: false

  alias Webchat.Repo
  alias Webchat.Accounts
  alias Webchat.Chat.Chatroom
  alias Webchat.Chat.Message


  def create_chatroom(attrs \\ %{}) do
    %Chatroom{}
    |> Chatroom.changeset(attrs)
    |> Repo.insert()
  end

  def add_message(%Accounts.User{id: user_id}, chatroom_id, attrs) do
    %Message{user_id: user_id, chatroom_id: chatroom_id}
    |> Message.changeset(attrs)
    |> Repo.insert()
  end

  def get_chatroom_messages(%Chatroom{} = room) do
    Message
    |> chatroom_messages_query(room)
    |> Repo.all()  
  end

  defp chatroom_messages_query(query, %Chatroom{id: chatroom_id}) do
    from( v in query, where: v.chatroom_id == ^chatroom_id)
  end

    

end
