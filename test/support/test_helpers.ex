defmodule Webchat.TestHelpers do

  alias Webchat.Repo
  alias Webchat.Administration.Models.Admin
  alias Webchat.Administration.Models.User
  alias Webchat.Chat.Models.Server
  alias Webchat.Chat.Models.Chatroom
  alias Webchat.Chat.Models.Message

  alias Webchat.Chat.Messages
  alias Webchat.Chat.Chatrooms
  alias Webchat.Chat.Servers
  alias Webchat.Administration.Users


  def admin_fixture(user) do
    %Admin{user_id: user.id}
    |> Admin.changeset(%{})
    |> Repo.insert()
  end

  @valid_attrs %{email: "some@email", password: "some password", username: "some username"}
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(@valid_attrs)
      |> Users.create()

    # We normally don't see user password outside of creation
    # We remove it for equality in our tests
    user = %User{user | password: nil}
    user
  end

  def chatroom_fixture(%Server{} = server) do
    {:ok, %Chatroom{} = room} =
      Chatrooms.create_chatroom(server.id, %{roomname: "some name"})

    room
  end

  @valid_attrs %{content: "some content"}
  def message_fixture(%User{} = user, %Chatroom{} = room) do
    {:ok, %Message{} = message} = Messages.add_message(user, room.id, @valid_attrs)
    message = %Message{message | user:  user}
    message
  end

  @valid_attrs %{name: "some name"}
  def server_fixture(attrs \\ %{}) do
    {:ok, server} =
      attrs
      |> Enum.into(@valid_attrs)
      |> Servers.create_server()

    server
  end

end
