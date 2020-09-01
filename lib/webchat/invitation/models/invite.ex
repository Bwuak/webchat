defmodule Webchat.Invitation.Models.Invite do
  use Ecto.Schema
  import Ecto.Changeset

  alias Webchat.Chat.Models.Server

  @primary_key {:uuid, :binary_id, autogenerate: true} 
  schema "invites" do
    belongs_to :server, Server 

    timestamps()
  end

  def changeset(invite, attrs) do
    invite
    |> cast(attrs, [:server_id])
    |> validate_required([:server_id])
    |> assoc_constraint(:server)
  end

end
