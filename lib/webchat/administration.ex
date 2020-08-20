defmodule Webchat.Administration do

  alias Webchat.Administration.Models.User
  alias Webchat.Administration.Admins
  alias Webchat.Administration.Users
  alias Webchat.Administration.Encryption


  @doc """
  Validates the user is admin
  """
  def is_admin?(%User{} = user) do
    Admins.get_by(%{user_id: user.id}) != nil
  end

  @doc """
  Gives user for correct credentials
  """
  def authenticate_user(email, given_pass) do
    down_cased_email = String.downcase email
    user = Users.get_by(email: down_cased_email)

    cond do
      user && Encryption.verify_pass(given_pass, user.password_hash) -> 
        {:ok, user}

      user ->
        {:error, :unauthorized}

      true ->
        {:error, :not_found}
    end
  end

end
