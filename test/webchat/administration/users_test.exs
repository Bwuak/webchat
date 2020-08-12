defmodule Webchat.Administration.UsersTest do
  use Webchat.DataCase, async: true

  alias Webchat.Administration.Users
  alias Webchat.Administration.Users.User


  @valid %{email: "some@email", password: "some password", username: "some username"}
  @invalid %{email: nil, password: nil, username: "x"}

  test "list/0 returns all users" do
    user = user_fixture()
    assert Users.list() == [%User{user | password: nil}]
  end

  test "get!/1 returns the user with given id" do
    user = user_fixture()
    assert Users.get!(user.id) == %User{user | password: nil}
  end

  test "create/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = Users.create(@invalid)
  end

  test "create/1 with invalid length name returns error changeset" do
    attrs_with_long_name = 
      Map.put(@valid, :username, String.duplicate(@invalid.username, 21) )
    attrs_with_short_name = Map.put(@valid, :username, @invalid.username)
    {:error, _changeset} = Users.create(attrs_with_long_name)
    {:error, _changeset} = Users.create(attrs_with_short_name)

    assert Users.list() == []
  end

  test "delete/1 deletes the user" do
    user = user_fixture()
    assert {:ok, %User{}} = Users.delete(user)
    assert_raise Ecto.NoResultsError, fn -> Users.get!(user.id) end
  end

end
