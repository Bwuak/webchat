defmodule Webchat.Repo.Migrations.CreateServers do
  use Ecto.Migration

  def change do
    create table(:servers) do
      add :name, :string
      add :user_id, references(:users)

      timestamps()
    end

    alter table(:chatrooms) do
      add :server_id, references(:servers)
    end

    create index(:chatrooms, [:server_id])
  end
end
