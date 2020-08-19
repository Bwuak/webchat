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
    |> validate_required([:role_id, :user_id, :server_id])
    |> assoc_constraint(:user)
    |> assoc_constraint(:server)
    |> assoc_constraint(:role)
  end

end
