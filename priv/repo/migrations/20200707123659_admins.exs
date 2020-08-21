defmodule Webchat.Repo.Migrations.Administration.Admins do
  use Ecto.Migration

  def change do
    create table(:admins) do
      # on_delete: :nothing -> an admin user will not be deleted
      add :user_id, references(:users, on_delete: :nothing), null: false

      timestamps()
    end
  end
end
