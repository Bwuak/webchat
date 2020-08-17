defmodule Webchat.Chat.MessagesTest do
  use Webchat.DataCase, async: true

  alias Webchat.Chat.Models.Message 
  alias Webchat.Chat.Messages

  @valid_attrs %{content: "some message"}
  @invalid_attrs %{content: "               "}

  
  test "add_message/3 creates a message with a valid user, chatroom and content" do
    user = user_fixture()
    server = server_fixture(%{user_id: user.id})
    room = chatroom_fixture(server)

    {:ok, %Message{} = message} =
      Messages.add_message(user, room.id, @valid_attrs)
    assert message.content == "some message"
  end
  
  test "add_message/3 new message is added to a room" do
    user = user_fixture()
    server = server_fixture(%{user_id: user.id})
    room = chatroom_fixture(server)

    {:ok, %Message{} = message} =
      Messages.add_message(user, room.id, @valid_attrs)

    message = %Message{message | user: user}
    messages = Messages.list_for(room)
    assert messages == [message]
  end

  test "add_message/3 empty message is ignored"  do
    user = user_fixture()
    server = server_fixture(%{user_id: user.id})
    room = chatroom_fixture(server)

    {:error, _err} = Messages.add_message(user, room.id, @invalid_attrs)

    messages = Messages.list_for(room)
    assert messages == []
  end

  test "Messages.list_for/2 gives up to 50 messages older than
  the last message seen" do
    user = user_fixture()
    server = server_fixture(%{user_id: user.id})
    room = chatroom_fixture(server)

    older_message = message_fixture(user, room)
    old_messages = 
      for _msg <- 1..50 do message_fixture(user, room) end

    oldest_message_seen = message_fixture(user, room)

    queried_messages = 
      Messages.list_for(room, oldest_message_seen.id)
    
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

    queried_messages = Messages.list_for(room)

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

    _queried_messages = Messages.list_for(room, last_seen_message.id)

    assert queried_messages = new_unseen_messages
    assert not Enum.member?(queried_messages, last_seen_message)
    assert "comebacklater" == ""
  end

end
