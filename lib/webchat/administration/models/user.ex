defmodule Webchat.Administration.Models.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :username, :string
    field :email, :string
    field :password_hash, :string
    field :password, :string, virtual: true

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username])
    |> validate_required([:username ])
    |> validate_length(:username, min: 2, max: 20)
  end

  def registration_changeset(user, attrs) do
    user
    |> changeset(attrs)
    |> cast(attrs, [:email, :password])
    |> validate_required([:email, :password])
    |> validate_length(:password, min: 6, max: 100)
    |> update_change(:email, &String.downcase/1)
    |> unique_constraint(:email)
    |> put_pass_hash()
  end

  # Hash the user's password
  defp put_pass_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
          put_change(changeset, :password_hash, Pbkdf2.hash_pwd_salt(pass))
          
        _ ->
          changeset
    end
  end

end
