defmodule Webchat.ChatTest do
  use Webchat.DataCase, async: true

  alias Webchat.Administration.Users.User
  alias Webchat.Chat
  alias Webchat.Chat.Chatroom
  alias Webchat.Chat.Message


  describe "chatroom" do
    @valid_attrs %{roomname: "general"}
    @invalid_attrs %{roomname: ""}

    test "create_chatroom/1 with valid data creates a chatroom" do
      user = user_fixture()
      server = server_fixture(%{user_id: user.id})

      assert {:ok, %Chatroom{} = room} =
        Chat.create_chatroom(server.id, @valid_attrs)
      assert room.roomname == "general"
    end

    test "create_chatroom/1 with invalid name doesn't create a chatroom" do
      assert {:error, %Ecto.Changeset{}} =
        Chat.create_chatroom(@invalid_attrs)
    end

    test "get_all_chatrooms/0 returns all chatrooms" do
      user = user_fixture()
      server = server_fixture(%{user_id: user.id})
      room = chatroom_fixture(server)
      
      chatrooms = Chat.get_all_chatrooms()
      assert chatrooms == [room]
    end

  end # chatroom tests


  describe "message" do
    @valid_attrs %{content: "some message"}
    @invalid_attrs %{content: "               "}

    defp chatroom_fixture(%Chat.Server{} = server) do
      {:ok, %Chatroom{} = room} =
        Chat.create_chatroom(server.id, %{roomname: "some name"})

      room
    end

    defp message_fixture(%User{} = user, %Chatroom{} = room) do
      {:ok, %Message{} = message} = Chat.add_message(user, room.id, @valid_attrs)
      message = %Message{message | user:  user}
      message
    end

    test "add_message/3 creates a message with a valid user, chatroom and content" do
      user = user_fixture()
      server = server_fixture(%{user_id: user.id})
      room = chatroom_fixture(server)

      {:ok, %Message{} = message} =
        Chat.add_message(user, room.id, @valid_attrs)
      assert message.content == "some message"
    end
    
    test "add_message/3 new message is added to a room, a room lists all it's messages" do
      user = user_fixture()
      server = server_fixture(%{user_id: user.id})
      room = chatroom_fixture(server)

      {:ok, %Message{} = message} =
        Chat.add_message(user, room.id, @valid_attrs)

      message = %Message{message | user: user}
      messages = Chat.get_chatroom_messages(room)
      assert messages == [message]
    end

    test "add_message/3 empty message is ignored"  do
      user = user_fixture()
      server = server_fixture(%{user_id: user.id})
      room = chatroom_fixture(server)

      {:error, _err} = Chat.add_message(user, room.id, @invalid_attrs)

      messages = Chat.get_chatroom_messages(room)
      assert messages == []
    end

    test "get_chatroom_old_messages/2 gives up to 50 messages older than
    the last message seen" do
      user = user_fixture()
      server = server_fixture(%{user_id: user.id})
      room = chatroom_fixture(server)

      older_message = message_fixture(user, room)
      old_messages = 
        for _msg <- 1..50 do message_fixture(user, room) end

      oldest_message_seen = message_fixture(user, room)

      queried_messages = 
        Chat.get_chatroom_old_messages(room, oldest_message_seen.id)
      
      assert length(old_messages) == 50
      assert length(queried_messages) == 50
      assert not Enum.member?(queried_messages, oldest_message_seen)
      assert not Enum.member?(queried_messages, older_message)
      assert queried_messages == old_messages
      # makes sure we get the right 50 messages and are in the right order
    end

    test "charoom_messages/1 gives up to 50 messages when no message seen" do
      user = user_fixture()
      server = server_fixture(%{user_id: user.id})
      room = chatroom_fixture(server)

      older_message = message_fixture(user, room)
      old_messages = 
        for _msg <- 1..50 do message_fixture(user, room) end

      queried_messages = Chat.chatroom_messages(room)

      assert not Enum.member?(queried_messages, older_message)
      assert queried_messages == old_messages
    end

    test "chatroom_message/2 gives all messages since last seen" do
      user = user_fixture()
      server = server_fixture(%{user_id: user.id})
      room = chatroom_fixture(server)

      last_seen_message = message_fixture(user, room)
      new_unseen_messages = 
        for _msg <- 1..100 do message_fixture(user, room) end

      _queried_messages = Chat.chatroom_messages(room, last_seen_message.id)

      assert queried_messages = new_unseen_messages
      assert not Enum.member?(queried_messages, last_seen_message)
      assert "comebacklater" == ""
    end

  end #message tests


  describe "servers" do
    alias Webchat.Chat.Server

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def server_fixture(attrs \\ %{}) do
      {:ok, server} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Chat.create_server()

      server
    end

    test "list_servers/0 returns all servers" do
      user = user_fixture()
      server = server_fixture(%{user_id: user.id})

      assert Chat.list_servers() == [server]
    end

    test "get_server!/1 returns the server with given id" do
      user = user_fixture()
      server = server_fixture(%{user_id: user.id})

      assert Chat.get_server!(server.id) == server
    end

    test "create_server/1 with valid data creates a server" do
      user = user_fixture()
      assert {:ok, %Server{} = server} =
        Chat.create_server(Map.put(@valid_attrs, :user_id, user.id))
      assert server.name == "some name"
    end

    test "create_server/1 requires user id" do
      assert {:error, %Ecto.Changeset{}} = Chat.create_server(@valid_attrs)
    end

    test "create_server/1 requires valid data" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = 
        Chat.create_server(Map.put(@invalid_attrs, :user_id, user.id))
    end

    test "update_server/2 with valid data updates the server" do
      user = user_fixture()
      server = server_fixture(%{user_id: user.id})
      assert {:ok, %Server{} = server} = Chat.update_server(server, @update_attrs)
      assert server.name == "some updated name"
    end

    test "update_server/2 with invalid data returns error changeset" do
      user = user_fixture() 
      server = server_fixture(%{user_id: user.id})
      assert {:error, %Ecto.Changeset{}} = Chat.update_server(server, @invalid_attrs)

      # fetched_server needs user for equality
      fetched_server = Map.put(Chat.get_server!(server.id), :user, server.user)
      assert server == fetched_server 
    end

    test "delete_server/1 deletes the server" do
      user = user_fixture()
      server = server_fixture(%{user_id: user.id})
      assert {:ok, %Server{}} = Chat.delete_server(server)
      assert_raise Ecto.NoResultsError, fn -> Chat.get_server!(server.id) end
    end

    test "change_server/1 returns a server changeset" do
      user = user_fixture()
      server = server_fixture(%{user_id: user.id})
      assert %Ecto.Changeset{} = Chat.change_server(server)
    end
  end #server tests
end #module
