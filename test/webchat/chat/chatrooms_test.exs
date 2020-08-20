defmodule Webchat.Chat.ChatroomsTest do
  use Webchat.DataCase, async: true

  alias Webchat.Chat.Models.Chatroom
  alias Webchat.Chat.Chatrooms


  @valid %{roomname: "general"}
  @invalid %{roomname: ""}

  test "create/1 with valid data creates a chatroom" do
    user = user_fixture()
    server = server_fixture(user)

    assert {:ok, %Chatroom{} = room} =
      Chatrooms.create(server.id, @valid)
    assert room.roomname == @valid.roomname 
  end

  test "create/1 with invalid name doesn't create a chatroom" do
    assert {:error, %Ecto.Changeset{}} =
      Chatrooms.create(@invalid)
  end

end
