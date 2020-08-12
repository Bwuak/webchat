defmodule Webchat.Chat.Chatrooms do
  import Ecto.Query, warn: false

  alias Webchat.Repo
  alias Webchat.Chat.Models.Chatroom

  def create_chatroom(server_id, attrs \\ %{}) do
    %Chatroom{server_id: server_id}
    |> Chatroom.creation_changeset(attrs)
    |> Repo.insert()
  end

  def get_all_chatrooms() do
    Chatroom
    |> Repo.all
  end

  def get_chatroom!(chatroom_id), do: Repo.get!(Chatroom, chatroom_id)
  def get_chatroom(chatroom_id), do: Repo.get(Chatroom, chatroom_id)

  def change_chatroom(%Chatroom{} = chatroom, attrs \\ %{}) do
    Chatroom.changeset(chatroom, attrs)
  end

end
