defmodule Webchat.Chat.ServerParticipation do
  import Ecto.Query, warn: false

  alias Webchat.Repo
  alias Webchat.Administration.Models.User
  alias Webchat.Chat.Models.Participant
  alias Webchat.Chat.Models.Server
  alias Webchat.Chat.Roles


  @doc """
  Create a link between a user and a server with a role
  - A new participant is created with a "Member" role
  """
  def join(%Server{} = server, %User{} = user) do
    role = Roles.get!("Member") 

    %Participant{}
    |> Participant.changeset(
      %{user_id: user.id, role_id: role.id, server_id: server.id} )
    |> Repo.insert()
  end

  @doc """
  A user leaves a server
  """
  def leave(%Server{} = server, %User{} = user) do
    Repo.get_by!(Participant, %{server_id: server.id, user_id: user.id})
    |> Repo.delete!()
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
