defmodule Webchat.Administration.Users do
  import Ecto.Query, warn: false
  
  alias Webchat.Repo
  alias Webchat.Administration.Models.User


  def list(), do: Repo.all(User)

  def list_with_ids(ids) do
    Repo.all(from(user in User, where: user.id in ^ids))
  end

  def get!(id), do: Repo.get!(User, id)
  def get(id), do: Repo.get(User, id)

  def get_by(params), do: Repo.get_by(User, params)

  def create(attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  def update(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def delete(%User{} = user), do: Repo.delete(user)

  def change(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end
 
end
