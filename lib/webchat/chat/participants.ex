defmodule Webchat.Chat.Participants do
  import Ecto.Query, warn: false

  alias Webchat.Repo
  alias Webchat.Administration.Models.User
  alias Webchat.Chat.Models.Participant
  alias Webchat.Chat.Models.Server
  alias Webchat.Chat.Models.Role


  @doc """
  Create a link between a user and a server with a role
  """
  def create_participation(
    %User{} = user, %Role{} = role, %Server{} = server
  ) do
    %Participant{}
    |> Participant.changeset(
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
    Participant.changeset(participant, %{role_id: role.id})
    |> Repo.update()
  end

  @doc """
  TODO Transfer ownership of a server
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
  List servers associated with given user
  """
  def list_servers(%User{} = user) do
    from( s in Server,
      join: p in Participant,
      on: p.server_id == s.id,
      where: p.user_id == ^user.id
    )
    |> Repo.all()
  end

end
