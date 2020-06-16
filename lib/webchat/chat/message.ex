defmodule Webchat.Chat.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :content, :string

    belongs_to :chatroom, Webchat.Chat.Chatroom
    belongs_to :user, Webchat.Accounts.User

    timestamps()
  end


  def changeset(message, attrs) do
    message
    |> cast(attrs, [:content])
    |> validate_required([:content])
  end


end
 
