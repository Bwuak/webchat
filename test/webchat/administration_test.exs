defmodule Webchat.AdministrationTest do
  use Webchat.DataCase, async: true

  alias Webchat.Administration
  alias Webchat.Administration.Models.User


  test "is_admin?/1 returns true if user is admin" do
    user = user_fixture()
    admin_fixture(user)

    assert Administration.is_admin?(user) == true
  end


  # We need to know the user's password
  @valid_attrs %{password: "some random pas"}
  test "authenticate_user/2 returns a user with valid attrs" do
    user = user_fixture( %{password: @valid_attrs.password} )

    assert {:ok, %User{} = fetched_user} = 
      Administration.authenticate_user(user.email, @valid_attrs.password)
    assert fetched_user.password == nil
    assert user == fetched_user
  end

end
