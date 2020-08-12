defmodule Webchat.Chat.Models.Participant do
  use Ecto.Schema

  import Ecto.Changeset


  @primary_key false 
  schema "participants" do
    belongs_to :server, Webchat.Chat.Models.Server, [primary_key: true]
    belongs_to :user, Webchat.Administration.Models.User, [primary_key: true]
    belongs_to :role, Webchat.Chat.Models.Role
    
    timestamps()
  end

  def changeset(participant, attrs) do
    participant
    |> cast(attrs, [:role_id, :user_id, :server_id])
  end

  @doc "Change a user's role inside a server"
  def role_changeset(participant, attrs) do
    participant 
    |> changeset(attrs)
    |> validate_required([:role_id])
    |> assoc_constraint(:role)
  end

  @doc "Create a new participant"
  def creation_changeset(participant, attrs) do
    participant
    |> role_changeset(attrs)
    |> validate_required([:user_id, :server_id])
    |> assoc_constraint(:user)
    |> assoc_constraint(:server)
  end

end
