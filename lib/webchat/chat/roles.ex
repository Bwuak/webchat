defmodule Webchat.Chat.Roles do
  import Ecto.Query, warn: false

  alias Webchat.Repo
  alias Webchat.Chat.Models.Role


  def create(attrs) do
    %Role{}
    |> Role.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Fetching %Role{} for a given role name
  """
  def get!(role_name), do: Repo.get_by!(Role, %{name: role_name}) 

end
