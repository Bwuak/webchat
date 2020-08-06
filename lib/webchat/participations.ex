defmodule Webchat.Participations do
  import Ecto.Query

  alias Webchat.Repo
  alias Webchat.Accounts.User
  alias Webchat.Chat.Server
  alias Webchat.Participations.Participant
  alias Webchat.Participations.Role

  @doc """
  Create a link between a user and a server with a role
  """
  def create_paticipation(attrs) do
    %Participant{}
    |> Participant.creation_changeset(attrs)
    |> Repo.insert()
  end
  
  @doc """
  Remove the link between a user and a server
  """
  def delete_participation(%Participant{} = participation) do
    Repo.delete(participation)
  end

  @doc """
  Change a user's role inside a server
  """
  def update_role(%Participant{} = participant, %Role{} = role) do
    Participant.role_changeset(participant, %{role_id: role.id})
    |> Repo.update()
  end

  @doc """
  Transfer ownership of a server
  """
  def transfer_ownership(%Participant{} = _owner, %Participant{} = _new_owner) do
    :nil
  end

  @doc """
  Get all participants inside a server
  """
  def list_participants(%Server{} = server) do
  end

end
