defmodule Webchat.Chat.Roles do
  import Ecto.Query, warn: false

  alias Webchat.Repo
  alias Webchat.Chat.Models.Role


  table = :ets.new(:roles_registry, [:set, :protected])
  :ets.insert(table, {"member", self()})

  def create(attrs) do
    %Role{}
    |> Role.changeset(attrs)
    |> Repo.insert()
  end

  def get!(:member), do: :ets.lookup(:roles_registry, "member")
  def get!(role_name) do
    Repo.get_by!(Role, %{name: role_name} ) 
  end

end
