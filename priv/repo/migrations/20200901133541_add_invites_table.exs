defmodule Webchat.Repo.Migrations.AddInvitesTable do
  use Ecto.Migration

  def change do
    create table(:invites, primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :server_id, references(:servers), [null: false]

      timestamps()
    end

    create index(:invites, [:server_id], unique: true) 
  end
end
