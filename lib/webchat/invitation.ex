defmodule Webchat.Invitation do
  alias Webchat.Administration.Models.User
  alias Webchat.Invitation.Models.Invite
  alias Webchat.Chat.Models.Participant

  alias Webchat.Chat.Participants

  @doc """
  Link a user with a server with an invitation
  User must not already be affiliated with the server
  """
  def redeem_invite(%User{} = user, %Invite{} = invite) do
    case Participants.get(user, invite.server_id) do
      %Participant{} ->
        nil

      _ -> 
        Participants.create(user, invite.server_id)
    end
  end

end
