defmodule Webchat.Chat.Participants do
  import Ecto.Query, warn: false

  alias Webchat.Repo
  alias Webchat.Chat.Models.Participant
  alias Webchat.Administration.Models.User


  def create(%User{} = user, serverId) do
    %Participant{user_id: user.id, server_id: serverId}
    |> Participant.changeset(%{})
    |> Repo.insert()
  end

  def get(%User{} = user, serverId) do
    Repo.get_by(Participant, %{user_id: user.id, server_id: serverId})
  end

  def delete(%Participant{} = participation) do
    Repo.delete(participation)
  end

  def change(%Participant{} = participant, attrs \\ %{}) do 
    Participant.changeset(participant, attrs) 
    |> Repo.update()
  end

end
