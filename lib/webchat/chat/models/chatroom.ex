defmodule Webchat.Chat.Models.Chatroom do
  use Ecto.Schema
  import Ecto.Changeset

  alias Webchat.Chat.Models.Message
  alias Webchat.Chat.Models.Server

  schema "chatrooms" do
    field :roomname, :string

    has_many :messages, Message
    belongs_to :server, Server

    timestamps()
  end

  def changeset(room, attrs) do
    room 
    |> cast(attrs, [:roomname, :server_id])
    |> validate_required([:roomname, :server_id])
    |> validate_length(:roomname, min: 2, max: 20)
    |> assoc_constraint(:server)
  end

end
