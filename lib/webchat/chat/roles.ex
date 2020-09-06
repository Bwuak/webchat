defmodule Webchat.Chat.Roles do
  import Ecto.Query, warn: false

  alias Webchat.Chat.Models.Role

  # Roles determined at compile time
  # Make sure they're the same as DB
  # Could use ets...
  @roles [
    %Role{name: "member"},
    %Role{name: "banned"}
  ]


  @doc """
  Fetching %Role{} for a given role name
  """
  def get!(role_name) do
    role = 
      Enum.find(@roles, fn role -> role.name == role_name end)

    if role, do: role, else: raise "invalid role"
  end

end
