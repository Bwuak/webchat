defmodule Webchat.Administration.Users do
  import Ecto.Query, warn: false
  alias Webchat.Repo

  alias Webchat.Administration.Users.User


  def list_users do
    Repo.all(User)
  end

  def get_users_with_ids(ids) do
    Repo.all(from(user in User, where: user.id in ^ids))
  end

  def get_user!(id), do: Repo.get!(User, id)
  def get_user(id), do: Repo.get(User, id)

  def get_user_by(params) do
    Repo.get_by(User, params)
  end

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end
 
end
