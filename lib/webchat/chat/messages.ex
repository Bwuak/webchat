defmodule Webchat.Chat.Messages do
  import Ecto.Query, warn: false

  alias Webchat.Repo
  alias Webchat.Administration.Models.User
  alias Webchat.Chat.Models.Chatroom
  alias Webchat.Chat.Models.Message



  @doc """
  gives up to 50 messages older than oldest seen, chatroom history

  @high_oldest_seen_id replaces oldest id when none provided
  """
  @high_oldest_seen_id 90000000000
  def list_for(room, oldest \\ @high_oldest_seen_id) 

  def list_for(%Chatroom{} = room, oldest_id) 
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

  def list_for(%Chatroom{} = room, _) do 
    list_for(room, @high_oldest_seen_id)
  end

  @doc """
  A user creates a new message inside a chatroom
  """
  def add_message(%User{id: user_id}, chatroom_id, attrs) do
    %Message{user_id: user_id, chatroom_id: chatroom_id}
    |> Message.changeset(attrs)
    |> Repo.insert()
  end

end
