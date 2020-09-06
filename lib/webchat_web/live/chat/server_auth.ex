defmodule WebchatWeb.Chat.ServerAuth do

  alias Webchat.Administration.Models.User
  alias Webchat.Chat.Models.Participant
  alias Webchat.Chat.Participants
  alias Webchat.Chat.Servers

  @doc """
  A user attempts to join a server
  4 possibilites

  User is linked to a server
    - banned => error message
    - member => ignore

  User has no link to the server
    - Server is private => error message
    - Server is public => create link between user and server
  """
  def try_join(serverId, _) when is_nil(serverId), do: true
  def try_join(serverId, %User{} = user) do
    server = Servers.get(serverId)
    participant = Participants.get(user, serverId)

    case participant do
      part = %Participant{} ->
        if part.role_name != "banned" do
          true
        else 
          send(self(), {__MODULE__, :error, "You are banned from this server"})
          false
        end
        
      nil ->
        if server && server.private == false do 
          Participants.create(user, serverId)
          true
        else 
          send(self(), {__MODULE__, :error, 
            "This server is either private or does not exist"})
          false
        end
    end
  end

end

