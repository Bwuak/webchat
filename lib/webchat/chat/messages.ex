defmodule Webchat.Chat.Messages do
  import Ecto.Query, warn: false

  alias Webchat.Repo
  alias Webchat.Administration.Models.User
  alias Webchat.Chat.Models.Chatroom
  alias Webchat.Chat.Models.Message


  def get_chatroom_messages(%Chatroom{id: chatroom_id}) do
    Message
    |> chatroom_messages_query(chatroom_id)
    |> Repo.all()  
  end

  @doc "gives up to 50 messages older than oldest seen, chatroom history"
  def get_chatroom_old_messages(%Chatroom{} = room, oldest_id) do
    Repo.all(
      from msg in Ecto.assoc(room, :messages),
      where: msg.id < ^oldest_id,
      order_by: [desc: msg.id],
      limit: 50,
      preload: [:user]
    )
    |> Enum.reverse
  end

  def chatroom_messages(room, last_seen_id \\ 0)
  @doc "get all the messages between last_seen_id and current msg,
  this happens when a user has changed server and comes back
  "
  def chatroom_messages(%Chatroom{} = room, last_seen_id) when last_seen_id > 0 do
    Repo.all(
      from msg in Ecto.assoc(room, :messages),
      where: msg.id > ^last_seen_id,
      order_by: [desc: msg.id],
      preload: [:user]
    )
    |> Enum.reverse
  end

  @doc "get 50 newest messages when a user join a chatroom"
  def chatroom_messages(%Chatroom{} = room, _) do
    Repo.all(
      from msg in Ecto.assoc(room, :messages),
      order_by: [desc: msg.id],
      limit: 50,
      preload: [:user]
    )
    |> Enum.reverse
  end

  defp chatroom_messages_query(query, chatroom_id) do
    from( v in query, 
      where: v.chatroom_id == ^chatroom_id,
      preload: [:user]
    )
  end


  def change_message(%Message{} = message, attrs \\ %{}) do
    Message.changeset(message, attrs)
  end

  def add_message(%User{id: user_id}, chatroom_id, attrs) do
    %Message{user_id: user_id, chatroom_id: chatroom_id}
    |> Message.changeset(attrs)
    |> Repo.insert()
  end

end
