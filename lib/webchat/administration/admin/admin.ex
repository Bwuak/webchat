defmodule Webchat.Administration.Admins.Admin do
  use Ecto.Schema
  import Ecto.Changeset

  schema "admins" do
    belongs_to :user, Webchat.Administration.Users.User

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:user_id])
    |> unique_constraint(:user)
  end

end
