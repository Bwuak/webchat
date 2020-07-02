defmodule Webchat.Accounts do
  import Ecto.Query, warn: false
  alias Webchat.Repo

  alias Webchat.Accounts.User

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

  def authenticate_user(email, given_pass) do
    down_cased_email = String.downcase email
    user = get_user_by(email: down_cased_email)

    cond do
      user && Pbkdf2.verify_pass(given_pass, user.password_hash) ->
        {:ok, user}

      user ->
        {:error, :unauthorized}

      true ->
        Pbkdf2.no_user_verify()
        {:error, :not_found}
    end
  end
end
