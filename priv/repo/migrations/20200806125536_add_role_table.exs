defmodule Webchat.Repo.Migrations.AddRoleTable do
  use Ecto.Migration

  def change do
    create table(:roles, primary_key: false) do
      add :name, :string, [null: false, primary_key: true]

      timestamps()
    end
  end

end
