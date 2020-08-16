defmodule Webchat.Chat.Messages do
  import Ecto.Query, warn: false

  alias Webchat.Repo
  alias Webchat.Administration.Models.User
  alias Webchat.Chat.Models.Chatroom
  alias Webchat.Chat.Models.Message


  @high_oldest_seen_id 900000000
  def get_chatroom_old_messages(room, oldest \\ @high_oldest_seen_id) 

  @doc "gives up to 50 messages older than oldest seen, chatroom history"
  def get_chatroom_old_messages(%Chatroom{} = room, oldest_id) 
      when is_integer(oldest_id) do
    Repo.all(
      from msg in Ecto.assoc(room, :messages),
      where: msg.id < ^oldest_id,
      order_by: [desc: msg.id],
      limit: 50,
      preload: [:user]
    )
    |> Enum.reverse
  end

  # Matches when no id provided
  def get_chatroom_old_messages(room, _) do 
    get_chatroom_old_messages(room, @high_oldest_seen_id)
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
