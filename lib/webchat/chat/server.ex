defmodule Webchat.Chat.Server do
  use Ecto.Schema
  import Ecto.Changeset

  schema "servers" do
    field :name, :string

    belongs_to :user, Webchat.Accounts.User
    has_many :chatrooms, Webchat.Chat.Chatroom

    timestamps()
  end

  @doc false
  def changeset(server, attrs) do
    server
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end

  def creation_changeset(server, attrs) do
    server
    |> changeset(attrs)
    |> put_assoc(:user, attrs.user)
    |> validate_required([:user])
    |> assoc_constraint(:user)
  end

end
