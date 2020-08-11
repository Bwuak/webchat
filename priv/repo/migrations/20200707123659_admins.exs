defmodule Webchat.Repo.Migrations.Administration.Admins do
  use Ecto.Migration

  def change do
    create table(:admins) do
      add :user_id, references(:users)

      timestamps()
    end
  end
end
