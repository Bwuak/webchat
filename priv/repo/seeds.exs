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
alias Webchat.Accounts.User

