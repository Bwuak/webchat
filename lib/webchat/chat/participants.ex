defmodule Webchat.Chat.Participants do
  import Ecto.Query, warn: false

  alias Webchat.Repo
  alias Webchat.Administration.Models.User
  alias Webchat.Chat.Models.Participant
  alias Webchat.Chat.Models.Server
  alias Webchat.Chat.Models.Role


  def create_participation(
    %User{} = user, 
    %Role{} = role, 
    %Server{} = server
  ) do
    %Participant{user_id: user.id, role_id: role.id, server_id: server.id}
    |> Participant.changeset(%{})
    |> Repo.insert()
  end
  
  def delete_participation(%Participant{} = participation) do
    Repo.delete(participation)
  end

  def change(%Participant{} = participant, attrs \\ %{}) do 
    Participant.changeset(participant, attrs) 
    |> Repo.update()
  end

end
