defmodule Webchat.Repo.Migrations.AddParticipantsTable do
  use Ecto.Migration

  def change do
    # The table will create a btree(server_id, user_id)
    create table(:participants, primary_key: false) do
      add :server_id, references(:servers, on_delete: :delete_all), [null: false, primary_key: true]
      add :user_id, references(:users, on_delete: :delete_all), [null: false, primary_key: true]
      add :role_name, references(:roles, column: :name, type: :string, on_delete: :nothing), [default: "member"] 

      timestamps()
    end

    create index(:participants, [:user_id], unique: false)
  end

end
