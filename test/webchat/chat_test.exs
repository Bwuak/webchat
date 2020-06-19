defmodule Webchat.ChatTest do
  use Webchat.DataCase, async: true

  alias Webchat.Accounts
  alias Webchat.Chat
  alias Webchat.Chat.Chatroom
  alias Webchat.Chat.Message


  describe "chatroom" do
    @valid_attrs %{roomname: "general"}
    @invalid_attrs %{roomname: ""}

    test "create_chatroom/1 with valid data creates a chatroom" do
      assert {:ok, %Chatroom{} = room} =
        Chat.create_chatroom(@valid_attrs)
      assert room.roomname == "general"
    end

    test "create_chatroom/1 with invalid name doesn't create a chatroom" do
      assert {:error, %Ecto.Changeset{}} =
        Chat.create_chatroom(@invalid_attrs)
    end

    test "get_all_chatrooms/0 returns all chatrooms" do
      room = chatroom_fixture()
      
      chatrooms = Chat.get_all_chatrooms()
      assert chatrooms == [room]
    end

  end


  describe "message" do
    @valid_attrs %{content: "some message"}
    @invalid_attrs %{content: "               "}

    defp chatroom_fixture() do
      {:ok, %Chatroom{} = room} =
        Chat.create_chatroom(%{roomname: "some name"})

      room
    end

    test "add_message/3 creates a message with a valid user, chatroom and content" do
      room = chatroom_fixture()
      user = user_fixture()

      {:ok, %Message{} = message} =
        Chat.add_message(user, room.id, @valid_attrs)
      assert message.content == "some message"
    end
    
    test "add_message/3 new message is added to a room, a room lists all it's messages" do
      room = chatroom_fixture()
      user = user_fixture()

      {:ok, %Message{} = message} =
        Chat.add_message(user, room.id, @valid_attrs)

      user = %Accounts.User{user | password: nil}
      message = %Message{message | user: user}
      messages = Chat.get_chatroom_messages(room)
      assert messages == [message]
    end

    test "add_message/3 empty message is ignored"  do
      room = chatroom_fixture()
      user = user_fixture()

      {:error, _err} = Chat.add_message(user, room.id, @invalid_attrs)

      messages = Chat.get_chatroom_messages(room)
      assert messages == []
    end

  end

end
