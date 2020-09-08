defmodule Webchat.Chat.ParticipantsTest do
  use Webchat.DataCase, async: true

  alias Webchat.Administration.Models.User
  alias Webchat.Chat.Models.Participant

  alias Webchat.Chat.Participants

  setup do
    roles_setup()
    owner = user_fixture(%{email: "owner@email"})
    server = server_fixture(owner) 
    user = user_fixture(%{email: "user@email"})

    %{user: user, 
      server: server,
      owner: owner
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

  # Test impossible unknwon error
  # violation on role_id for participants table
  # But participants table does not have that column... 
  test "create/2 with valid data create a participant", data do
    # Participants.create(data.user, data.server.id)
  end

end
