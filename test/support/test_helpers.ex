defmodule Webchat.TestHelpers do
  alias Webchat.Accounts 

  @valid_attrs %{email: "some@email", password: "some password", username: "some username"}


  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(@valid_attrs)
      |> Accounts.create_user()

    user = %Accounts.User{user | password: nil}
    user
  end

end
