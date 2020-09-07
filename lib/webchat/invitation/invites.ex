defmodule Webchat.Invitation.Invites do 
  import Ecto.Query, warn: false

  alias Webchat.Repo
  alias Webchat.Chat.Models.Server
  alias Webchat.Invitation.Models.Invite

  def get(%Server{} = server) do
    Repo.get_by(Invite, %{server_id: server.id})
  end

  def get(invitation_id) do
    Repo.get(Invite, invitation_id)
  end

  def create(%Server{} = server) do
    %Invite{server_id: server.id}
    |> Repo.insert()
  end

  def delete(nil), do: nil 
  def delete(%Invite{} = invite) do
    Repo.delete(invite)
  end
  
end
