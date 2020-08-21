defmodule Webchat.Repo.Migrations.CreateServers do
  use Ecto.Migration

  def change do
    create table(:servers) do
      add :name, :string, null: false
      add :user_id, references(:users), null: false

      timestamps()
    end

    alter table(:chatrooms) do
      add :server_id, references(:servers), null: false
    end

    create index(:chatrooms, [:server_id])
  end
end
