defmodule Webchat.Chat.Chatrooms do
  import Ecto.Query, warn: false

  alias Webchat.Repo
  alias Webchat.Chat.Models.Chatroom


  def create(server_id, attrs \\ %{}) do
    %Chatroom{server_id: server_id}
    |> Chatroom.changeset(attrs)
    |> Repo.insert()
  end

  def get!(chatroom_id), do: Repo.get!(Chatroom, chatroom_id)
  def get(chatroom_id), do: Repo.get(Chatroom, chatroom_id)

  def change(%Chatroom{} = chatroom, attrs \\ %{}) do
    Chatroom.changeset(chatroom, attrs)
  end

end
