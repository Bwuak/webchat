#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Webchat.Repo.insert!(%Webchat.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
use Webchat

# Create a user 
User.registration_changeset(%User{}, %{username: "admin", email: "admin@admin", password: "123456"})
|> Repo.insert!


# # get user 
user = Users.get_by(email: "admin@admin")

# # create servers 
{:ok, server1} = Servers.create(user, %{name: "First server"})
{:ok, server2} = Servers.create(user, %{name: "second server"} )
# 
# # create chatrooms 
Chatrooms.create(server2.id, %{roomname: "General"}) 
Chatrooms.create(server1.id, %{roomname: "General"})
Chatrooms.create(server1.id, %{roomname: "Another room"})
#  
# # create a website admin
{:ok, _admin} = Admin.changeset(%Admin{user_id: user.id}, %{}) |> Repo.insert()
 



# ccreate a role
Role.changeset(%Role{}, %{name: "Member"})
|> Repo.insert()

# Repo.get!(Role, 1) |> Repo.delete!()
Repo.all(Role) |> IO.inspect
#


# create a participant
user = Users.get_by(email: "admin@admin")
server = Repo.get_by(Server, %{name: "First server"}) 
role = Repo.get_by(Role, %{name: "Member"})
Participant.changeset(%Participant{}, 
  %{user_id: user.id,
    server_id: server.id,
    role_id: role.id}
) |> Repo.insert!()


