defmodule Webchat.Repo.Migrations.AddPrivaryServer do
  use Ecto.Migration

  def change do
    alter table(:servers) do
      add :private, :boolean, [null: false, default: false]
    end
  end
end
