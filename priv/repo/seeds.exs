#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Webchat.Repo.insert!(%Webchat.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
import Ecto.Query
alias Ecto.Changeset
alias Webchat.Repo
alias Webchat.Chat
alias Webchat.Chat.{Chatroom, Server, Message}
alias Webchat.Accounts
alias Webchat.Accounts.{User, Admin}

# Create a user 
User.registration_changeset(%User{}, %{username: "admin", email: "admin@admin", password: "123456"})
|> Repo.insert

# get user 
user = Accounts.get_user_by(email: "admin@admin")

# create servers 
{:ok, server1} = Chat.create_server(%{name: "ServerTwo", user: user})
{:ok, server2} = Chat.create_server(%{name: "server", user: user})

# create chatrooms 
Chat.create_chatroom(server2.id, %{roomname: "General"}) 
Chat.create_chatroom(server1.id, %{roomname: "General"})
Chat.create_chatroom(server1.id, %{roomname: "Another room"})
 
# create a website admin
user = Accounts.get_user!(user.id)
{:ok, _admin} = Admin.changeset(%Admin{user_id: user.id}, %{}) |> Repo.insert()

# creating server from changeset
%Server{}
|> Changeset.cast(%{name: "s2"}, [:name] )
|> Changeset.put_assoc(:user, user)
|> Changeset.validate_required([:name, :user])
|> IO.inspect
|> Repo.insert

