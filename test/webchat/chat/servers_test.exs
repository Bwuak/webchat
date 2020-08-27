defmodule Webchat.Chat.ServersTest do
  use Webchat.DataCase, async: true

  alias Webchat.Administration.Models.User
  alias Webchat.Chat.Servers
  alias Webchat.Chat.Models.Server

  @valid_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  test "list_servers/0 returns all servers" do
    user = user_fixture()
    server = server_fixture(user)

    assert Servers.list() == [server]
  end

  test "get_server!/1 returns the server with given id" do
    user = user_fixture()
    server = server_fixture(user)

    assert Servers.get!(server.id) == server
  end

  test "create/1 with valid data creates a server" do
    user = user_fixture()
    assert {:ok, %Server{} = server} =
      Servers.create(user, @valid_attrs)
    assert server.name == "some name"
  end

  @unregistred_user %User{username: "bobby", 
      password_hash: "a123asdaszxc", email: "some@email"}
  test "create/1 requires a registered user" do
    assert {:error, %Ecto.Changeset{}} = 
      Servers.create(@unregistred_user, @valid_attrs)
  end

  test "create/1 requires valid data" do
    user = user_fixture()
    assert {:error, %Ecto.Changeset{}} = 
      Servers.create(user, @invalid_attrs)
  end

  test "delete/1 deletes the server" do
    user = user_fixture()
    server = server_fixture(user)
    assert {:ok, %Server{}} = Servers.delete(server)
    assert_raise Ecto.NoResultsError, fn -> Servers.get!(server.id) end
  end

  test "update/2 with valid data updates the server" do
    user = user_fixture()
    server = server_fixture(user)
    assert {:ok, %Server{} = server} = Servers.update(server, @update_attrs)
    assert server.name == "some updated name"
  end

  test "update/2 with invalid data returns error changeset" do
    user = user_fixture() 
    server = server_fixture(user)
    assert {:error, %Ecto.Changeset{}} = Servers.update(server, @invalid_attrs)

    # fetched_server needs user for equality
    fetched_server = Map.put(Servers.get!(server.id), :user, server.user)
    assert server == fetched_server 
  end

  test "change/1 returns a server changeset" do
    user = user_fixture()
    server = server_fixture(user)
    assert %Ecto.Changeset{} = Servers.change(server)
  end

end
