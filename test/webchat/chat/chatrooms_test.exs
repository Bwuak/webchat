defmodule Webchat.Chat.ChatroomsTest do
  use Webchat.DataCase, async: true

  alias Webchat.Chat.Models.Chatroom
  alias Webchat.Chat.Chatrooms


  @valid %{roomname: "general"}
  @invalid %{roomname: ""}

  test "create_chatroom/1 with valid data creates a chatroom" do
    user = user_fixture()
    server = server_fixture(user)

    assert {:ok, %Chatroom{} = room} =
      Chatrooms.create_chatroom(server.id, @valid)
    assert room.roomname == @valid.roomname 
  end

  test "create_chatroom/1 with invalid name doesn't create a chatroom" do
    assert {:error, %Ecto.Changeset{}} =
      Chatrooms.create_chatroom(@invalid)
  end

  test "list/0 returns all chatrooms" do
    user = user_fixture()
    server = server_fixture(user)
    room = chatroom_fixture(server)
    
    chatrooms = Chatrooms.list()
    assert chatrooms == [room]
  end

end
