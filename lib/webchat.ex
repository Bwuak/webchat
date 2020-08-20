defmodule Webchat do
  @moduledoc """
  Webchat keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """


  # use Webchat
  # -> iex
  # -> playground
  # -> seeds
  @doc false
  defmacro __using__(_opts) do
    quote do
      import Ecto.Query
      alias Webchat.Repo
      alias Webchat.Administration.Models.User
      alias Webchat.Administration.Models.Admin
      alias Webchat.Chat.Models.Chatroom
      alias Webchat.Chat.Models.Role
      alias Webchat.Chat.Models.Message
      alias Webchat.Chat.Models.Server
      alias Webchat.Chat.Models.Participant

      alias Webchat.Administration
      alias Webchat.Administration.Users
      alias Webchat.Administration.Admins
      alias Webchat.Chat.Servers
      alias Webchat.Chat.Chatrooms
      alias Webchat.Chat.Participants
      alias Webchat.Chat.Messages
      alias Webchat.Chat.Roles
    end
  end

end
