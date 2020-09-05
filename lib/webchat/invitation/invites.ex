defmodule Webchat.Invitation.Invites do 
  import Ecto.Query, warn: false

  alias Webchat.Repo

  alias Webchat.Invitation.Models.Invite

  def get(invitation_id) do
    Repo.get(Invite, invitation_id)
  end

  def create() do
  end

  def delete() do
  end
  
end
