defmodule Webchat.Chat.Models.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :content, :string

    belongs_to :chatroom, Webchat.Chat.Models.Chatroom
    belongs_to :user, Webchat.Administration.Models.User

    timestamps()
  end

  # The changeset forces the content of the message to not be blank
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:content])
    |> validate_required([:content])
    |> assoc_constraint(:user)
  end


end
 
