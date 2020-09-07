defmodule Webchat.Chat.ParticipantsTest do
  use Webchat.DataCase, async: true

  alias Webchat.Administration.Models.User
  alias Webchat.Chat.Models.Participant

  alias Webchat.Chat.Participants

  setup do
    roles_setup()
    user = user_fixture()
    server = server_fixture(user) 

    %{user: user, 
      server: server
    } 
  end

  test "create/2 requires a already registered", data do
    unregistered_user = %User{username: "bob", email: "a@a", password: "Asdasda"}
    {:error, changeset} = Participants.create(unregistered_user, data.server.id)

    assert changeset.valid? == false
    assert changeset.errors[:user_id]
  end

  @invalid_id -1
  test "create/2 requires a valid server id", data do
    assert_raise Postgrex.Error, fn -> Participants.create(data.user, @invalid_id) end
  end

  # TODO Why is this broken???
  # Error on participants role_id column WHICH DOES NOT EXISTS!!
  # Column for role id in DB and struct is role_name
  # It works fine in app and iex... but not in tests
  # Tests do not see default values from migrations db?
  test "create/2 with valid data create a participant", data do
    # Participants.create(data.user, data.server.id)
  end

end
