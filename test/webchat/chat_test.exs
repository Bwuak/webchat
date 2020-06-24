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
      server = server_fixture()

      assert {:ok, %Chatroom{} = room} =
        Chat.create_chatroom(server.id, @valid_attrs)
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
      server = server_fixture()
      {:ok, %Chatroom{} = room} =
        Chat.create_chatroom(server.id, %{roomname: "some name"})

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
      server = server_fixture()
      assert Chat.list_servers() == [server]
    end

    test "get_server!/1 returns the server with given id" do
      server = server_fixture()
      assert Chat.get_server!(server.id) == server
    end

    test "create_server/1 with valid data creates a server" do
      assert {:ok, %Server{} = server} = Chat.create_server(@valid_attrs)
      assert server.name == "some name"
    end

    test "create_server/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Chat.create_server(@invalid_attrs)
    end

    test "update_server/2 with valid data updates the server" do
      server = server_fixture()
      assert {:ok, %Server{} = server} = Chat.update_server(server, @update_attrs)
      assert server.name == "some updated name"
    end

    test "update_server/2 with invalid data returns error changeset" do
      server = server_fixture()
      assert {:error, %Ecto.Changeset{}} = Chat.update_server(server, @invalid_attrs)
      assert server == Chat.get_server!(server.id)
    end

    test "delete_server/1 deletes the server" do
      server = server_fixture()
      assert {:ok, %Server{}} = Chat.delete_server(server)
      assert_raise Ecto.NoResultsError, fn -> Chat.get_server!(server.id) end
    end

    test "change_server/1 returns a server changeset" do
      server = server_fixture()
      assert %Ecto.Changeset{} = Chat.change_server(server)
    end
  end
end
