defmodule Webchat.Chat.Chatroom do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chatrooms" do
    field :roomname, :string

    has_many :messages, Webchat.Chat.Message
    belongs_to :server, Webchat.Chat.Server

    timestamps()
  end

  def changeset(room, attrs) do
    room 
    |> cast(attrs, [:roomname, :server_id])
    |> validate_required([:roomname])
    |> validate_length(:roomname, min: 2, max: 20)
  end

  def creation_changeset(room, attrs) do
    room 
    |> changeset(attrs)
    |> validate_required([:server_id])
    |> assoc_constraint(:server)
  end

end
