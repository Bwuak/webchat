defmodule Webchat.Chat.ServersTest do
  use Webchat.DataCase, async: true

  alias Webchat.Chat.Servers
  alias Webchat.Chat.Models.Server

  @valid_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  test "list_servers/0 returns all servers" do
    user = user_fixture()
    server = server_fixture(%{user_id: user.id})

    assert Servers.list() == [server]
  end

  test "get_server!/1 returns the server with given id" do
    user = user_fixture()
    server = server_fixture(%{user_id: user.id})

    assert Servers.get!(server.id) == server
  end

  test "create_server/1 with valid data creates a server" do
    user = user_fixture()
    assert {:ok, %Server{} = server} =
      Servers.create_server(Map.put(@valid_attrs, :user_id, user.id))
    assert server.name == "some name"
  end

  test "create_server/1 requires user id" do
    assert {:error, %Ecto.Changeset{}} = Servers.create_server(@valid_attrs)
  end

  test "create_server/1 requires valid data" do
    user = user_fixture()
    assert {:error, %Ecto.Changeset{}} = 
      Servers.create_server(Map.put(@invalid_attrs, :user_id, user.id))
  end

  test "update_server/2 with valid data updates the server" do
    user = user_fixture()
    server = server_fixture(%{user_id: user.id})
    assert {:ok, %Server{} = server} = Servers.update_server(server, @update_attrs)
    assert server.name == "some updated name"
  end

  test "update_server/2 with invalid data returns error changeset" do
    user = user_fixture() 
    server = server_fixture(%{user_id: user.id})
    assert {:error, %Ecto.Changeset{}} = Servers.update_server(server, @invalid_attrs)

    # fetched_server needs user for equality
    fetched_server = Map.put(Servers.get!(server.id), :user, server.user)
    assert server == fetched_server 
  end

  test "delete_server/1 deletes the server" do
    user = user_fixture()
    server = server_fixture(%{user_id: user.id})
    assert {:ok, %Server{}} = Servers.delete_server(server)
    assert_raise Ecto.NoResultsError, fn -> Servers.get!(server.id) end
  end

  test "change_server/1 returns a server changeset" do
    user = user_fixture()
    server = server_fixture(%{user_id: user.id})
    assert %Ecto.Changeset{} = Servers.change_server(server)
  end

end
