defmodule Webchat.Repo.Migrations.CreateChatroom do
  use Ecto.Migration

  def change do
    create table(:chatrooms) do
      add :roomname, :string, null: false

      timestamps()
    end


    create table(:messages) do
      add :content, :text, null: false
      add :user_id, references(:users, on_delete: :nilify_all)
      add :chatroom_id, references(:chatrooms), null: false

      timestamps()
    end
    create index(:messages, [:chatroom_id])
  end

end
