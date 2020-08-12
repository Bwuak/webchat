defmodule Webchat.Chat.Server do
  use Ecto.Schema
  import Ecto.Changeset

  schema "servers" do
    field :name, :string

    belongs_to :user, Webchat.Administration.Models.User
    has_many :chatrooms, Webchat.Chat.Chatroom

    timestamps()
  end

  @doc false
  def changeset(server, attrs) do
    server
    |> cast(attrs, [:name, :user_id])
    |> validate_required([:name])
    |> validate_length(:name, min: 2, max: 20)
  end

  def creation_changeset(server, attrs) do
    server
    |> changeset(attrs)
    |> validate_required([:user_id])
    |> assoc_constraint(:user)
  end

end
