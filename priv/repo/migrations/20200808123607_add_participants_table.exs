defmodule Webchat.Repo.Migrations.AddParticipantsTable do
  use Ecto.Migration

  def change do
    # The table will create a btree(server_id, user_id)
    create table(:participants, primary_key: false) do
      add :server_id, references(:servers), [null: false, primary_key: true]
      add :user_id, references(:users), [null: false, primary_key: true]
      add :role_id, references(:roles), null: false 

      timestamps()
    end

    create index(:participants, [:user_id], unique: false)
  end

end
