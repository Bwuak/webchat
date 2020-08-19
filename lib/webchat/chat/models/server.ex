defmodule Webchat.Chat.Models.Server do
  use Ecto.Schema
  import Ecto.Changeset

  schema "servers" do
    field :name, :string

    belongs_to :user, Webchat.Administration.Models.User
    has_many :chatrooms, Webchat.Chat.Models.Chatroom

    timestamps()
  end

  @doc false
  def changeset(server, attrs) do
    server
    |> cast(attrs, [:name, :user_id])
    |> validate_required([:name])
    |> validate_length(:name, min: 2, max: 20)
    |> validate_required([:user_id])
    |> assoc_constraint(:user)
  end

end
