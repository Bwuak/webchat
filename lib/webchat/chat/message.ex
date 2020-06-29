defmodule Webchat.Chat.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :content, :string

    belongs_to :chatroom, Webchat.Chat.Chatroom
    belongs_to :user, Webchat.Accounts.User

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
 
