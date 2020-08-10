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
|> Repo.insert!
# 
# # get user 
user = Accounts.get_user_by(email: "admin@admin")
# 
# # create servers 
{:ok, server1} = Chat.create_server(%{name: "First server", user_id: user.id})
{:ok, server2} = Chat.create_server(%{name: "second server", user_id: user.id})
# 
# # create chatrooms 
Chat.create_chatroom(server2.id, %{roomname: "General"}) 
Chat.create_chatroom(server1.id, %{roomname: "General"})
Chat.create_chatroom(server1.id, %{roomname: "Another room"})
#  
# # create a website admin
{:ok, _admin} = Admin.changeset(%Admin{user_id: user.id}, %{}) |> Repo.insert()
 


alias Webchat.Participations.Role

Role.changeset(%Role{}, %{name: "Member"})
|> Repo.insert()

# Repo.get!(Role, 1) |> Repo.delete!()
Repo.all(Role) |> IO.inspect
#


alias Webchat.Participations.Participant
user = Accounts.get_user_by(email: "admin@admin")
server = Repo.get_by(Server, %{name: "First server"}) 
role = Repo.get_by(Role, %{name: "Member"})
Participant.creation_changeset(%Participant{}, 
  %{user_id: user.id,
    server_id: server.id,
    role_id: role.id}
) |> Repo.insert!()


