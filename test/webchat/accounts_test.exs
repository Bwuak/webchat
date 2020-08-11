defmodule Webchat.Administration.AdminsTest do
  use Webchat.DataCase, async: true

  alias Webchat.Administration
  alias Webchat.Administration.Users
  alias Webchat.Administration.Users.User
  alias Webchat.Administration.Admins.Admin

  describe "users" do

    @valid_attrs %{email: "some@email", password: "some password", username: "some username"}
    @invalid_attrs %{email: nil, password: nil, username: nil}

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Users.list_users() == [%User{user | password: nil}]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Users.get_user!(user.id) == %User{user | password: nil}
    end

    test "create_user/1 with valid data creates an anthenticable user" do
      assert {:ok, %User{} = user} = Users.create_user(@valid_attrs)
      assert user.email == "some@email"
      assert user.username == "some username"
      assert {:ok, user} = Administration.authenticate_user("some@email", "some password") 
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Users.create_user(@invalid_attrs)
    end

    test "create_user/1 with invalid length name returns error changeset" do
      attrs_with_long_name = Map.put(@valid_attrs, :username, String.duplicate("x", 21))
      attrs_with_short_name = Map.put(@valid_attrs, :username, "x")
      {:error, _changeset} = Users.create_user(attrs_with_long_name)
      {:error, _changeset} = Users.create_user(attrs_with_short_name)

      assert Users.list_users() == []
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Users.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Users.get_user!(user.id) end
    end
  end

  describe "admin" do

    def admin_fixture(user) do
      %Admin{user_id: user.id}
      |> Admin.changeset(%{})
      |> Repo.insert()
    end

    test "is_admin?/1 returns true if user is admin" do
      user = user_fixture()
      admin_fixture(user)

      assert Administration.is_admin?(user) == true
    end


  end

end
