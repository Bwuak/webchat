# mix run priv/repo/playground.exs
import Ecto.Query
alias Ecto.Changeset
alias Webchat.Repo
alias Webchat.Chat.Models.Message
alias Webchat.Chat.Models.Chatroom
alias Webchat.Administration.Models.User
alias Webchat.Administration.Models.Admin

alias Webchat.Chat.Servers
alias Webchat.Administration.Admins

# --------- play with Ecto -- 
user = Repo.get_by!(User, username: "admin")

messages = from m in Message, as: :messages, 
  where: m.user_id == ^user.id
  # select: [m.content, m.user_id, m.chatroom_id]
Repo.all(messages) |> IO.inspect

user_messages = 
  from m in messages, 
  join: user in User, as: :users, on: m.user_id == user.id
  # select: [user.username, m.content, m.chatroom_id]

Repo.all(user_messages) |> IO.inspect

user_message_chatroom =
  from [messages: m, users: u] in user_messages,
  join: room in Chatroom, as: :chatrooms, on: room.id == m.chatroom_id,
  order_by: [asc: m.inserted_at],
  select: [u.username, m.content, room.roomname, m.inserted_at]

Repo.all(user_message_chatroom) 
|> IO.inspect
|> Enum.each(&( IO.puts("#{Enum.at(&1, 0)} said #{Enum.at(&1, 1)} in #{Enum.at(&1, 2)} at #{Enum.at(&1, 3)}.") ))

