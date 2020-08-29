defmodule Webchat.Chat.Models.Role do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:name, :string, []}
  schema "roles" do
    
    timestamps()
  end

  def changeset(role, attrs) do
    role
    |> cast(attrs, [:name]) 
    |> validate_required([:name])
  end

end
