defmodule Webchat.Chat.Participants do
  import Ecto.Query, warn: false

  alias Webchat.Repo
  alias Webchat.Chat.Models.Participant


  def create(%{
    :user_id => userId,
    :server_id => serverId
  }) do
    %Participant{user_id: userId, server_id: serverId}
    |> Participant.changeset(%{})
    |> Repo.insert()
  end

  def get_by(params), do: Repo.get_by(Participant, params)
  
  def delete(%Participant{} = participation) do
    Repo.delete(participation)
  end

  def change(%Participant{} = participant, attrs \\ %{}) do 
    Participant.changeset(participant, attrs) 
    |> Repo.update()
  end

end
