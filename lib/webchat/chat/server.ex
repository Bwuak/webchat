defmodule Webchat.Chat.Server do
  use Ecto.Schema
  import Ecto.Changeset

  schema "servers" do
    field :name, :string

    belongs_to :user, Webchat.Accounts.User
    has_many :chatroom, Webchat.Chat.Chatroom

    timestamps()
  end

  @doc false
  def changeset(server, attrs) do
    server
    |> cast(attrs, [:name, :user_id])
    |> validate_required([:name])
  end
end
