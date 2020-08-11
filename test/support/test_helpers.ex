defmodule Webchat.TestHelpers do
  alias Webchat.Administration.Users
  alias Webchat.Administration.Users.User

  @valid_attrs %{email: "some@email", password: "some password", username: "some username"}


  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(@valid_attrs)
      |> Users.create_user()

    # We normally don't see user password outside of creation
    # We remove it for equality in our tests
    user = %User{user | password: nil}
    user
  end

end
