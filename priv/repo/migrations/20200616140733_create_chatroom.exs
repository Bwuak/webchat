defmodule Webchat.Repo.Migrations.CreateChatroom do
  use Ecto.Migration

  def change do
    create table(:chatrooms) do
      add :roomname, :string

      timestamps()
    end


    create table(:messages) do
      add :content, :string
      add :user_id, references(:users, on_delete: :nothing) 
      add :chatroom_id, references(:chatrooms)

      timestamps()
    end
    create index(:messages, [:chatroom_id])
  end

end
