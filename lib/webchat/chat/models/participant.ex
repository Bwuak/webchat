defmodule Webchat.Chat.Models.Participant do
  use Ecto.Schema

  import Ecto.Changeset
  alias Webchat.Administration.Models.User
  alias Webchat.Chat.Models.Server
  alias Webchat.Chat.Models.Role


  @primary_key false 
  schema "participants" do
    belongs_to :server, Server, [primary_key: true]
    belongs_to :user, User, [primary_key: true]
    belongs_to :role, Role, [foreign_key: :role_name, references: :name]
    
    timestamps()
  end

  def changeset(participant, attrs) do
    participant
    |> cast(attrs, [:role_name, :user_id, :server_id])
    |> validate_required([:user_id, :server_id])
    |> assoc_constraint(:user)
    |> assoc_constraint(:server)
    |> assoc_constraint(:role)
  end

end
