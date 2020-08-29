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

user = Users.get_by(email: "admin@admin")

# create a website admin
{:ok, _admin} = Admin.changeset(%Admin{user_id: user.id}, %{}) |> Repo.insert()

# create a role
Role.changeset(%Role{}, %{name: "member"})
|> Repo.insert()

# create servers 
{:ok, server1} = Servers.create(user, %{name: "Server 1"})
 
# create chatrooms 
Chatrooms.create(server1.id, %{roomname: "General"}) 


# create a participant
role = Repo.get_by(Role, %{name: "member"})
Participant.changeset(%Participant{}, 
  %{user_id: user.id,
    server_id: server1.id,
    role_id: role.name}
) |> Repo.insert!()


