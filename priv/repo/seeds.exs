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
alias Webchat.Repo
alias Webchat.Chat
alias Webchat.Chat.{Chatroom, Server, Message}
alias Webchat.Accounts
alias Webchat.Accounts.{User, Admin}

# Create a user first then run the following
user = Accounts.get_user_by(email: "admin@admin")

# {:ok, server1} = Chat.create_server(%{name: "unoriginal server1", user_id: user.id})
# {:ok, server2} = Chat.create_server(%{name: "another server", user_id: user.id})
# 
# Chat.create_chatroom(server2.id, %{roomname: "First chatroom"}) 
# Chat.create_chatroom(server1.id, %{roomname: "Some chatroom"})
# Chat.create_chatroom(server1.id, %{roomname: "room"})

# create a website admin
user = Accounts.get_user!(user.id)
{:ok, _admin} = Admin.changeset(%Admin{user_id: user.id}, %{}) |> Repo.insert()

ans = Accounts.is_admin?(user)
IO.inspect ans
