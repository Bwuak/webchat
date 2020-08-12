defmodule Webchat.Participations do
  import Ecto.Query

  alias Webchat.Repo
  alias Webchat.Chat.Server
  alias Webchat.Administration.Models.User
  alias Webchat.Participations.Participant
  alias Webchat.Participations.Role

  @doc """
  Create a link between a user and a server with a role
  """
  def create_participation(
    %User{} = user, %Role{} = role, %Server{} = server
  ) do
    %Participant{}
    |> Participant.creation_changeset(
      %{user_id: user.id, role_id: role.id, server_id: server.id} )
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
    from( p in Participant,
      where: p.server_id == ^server.id,
      preload: [:user, :role]
    )
    |> Repo.all()
  end

  @doc """
  """
  def list_servers(%Webchat.Administration.Models.User{} = user) do
    from( p in Participant,
      where: p.user_id == ^user.id,
      preload: [:server]
    )
    |> Repo.all()
    |> Enum.map(&(&1.server))
  end

end
