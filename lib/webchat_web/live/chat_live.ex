defmodule WebchatWeb.ChatLive do
  use WebchatWeb, :live_view

  alias Webchat.Accounts
  alias Webchat.Chat
  alias Webchat.Chat.Server
  alias Webchat.Chat.Chatroom
  alias WebchatWeb.Chat.{
    ChatroomComponent,
    UserListComponent,
    ChatroomListingComponent,
    ServerListingComponent,
    UserComponent
  }


  def mount(_params, session, socket) do
    user = Accounts.get_user!(session["user_id"])
    servers = Chat.list_servers()

    {:ok, assign(socket, 
      servers: servers,
      user: user
    )}
  end

  def handle_params(%{"server_id" => sid, "room_id" => rid}, _url, socket) do
    selected_server = String.to_integer(sid) |> Chat.get_server!()
    chatrooms = select_chatrooms(selected_server) 
    selected_chatroom = String.to_integer(rid) |> Chat.get_chatroom!()

    case Enum.member?(chatrooms, selected_chatroom)  do
      true ->
        {:noreply, assign(socket,
          selected_server: selected_server,
          chatrooms: chatrooms,
          selected_chatroom: selected_chatroom 
          )}

      false ->
        {:noreply, push_patch(socket, to: "/chat", replace: true)}
    end
  end

  def handle_params(%{"server_id" => sid}, _url, socket) do
    selected_server = String.to_integer(sid) |> Chat.get_server!()
    chatrooms = select_chatrooms(selected_server) 

    {:noreply, assign(socket,
      selected_server: selected_server,
      chatrooms: chatrooms,
      selected_chatroom: select_first_room(chatrooms) 
      )}
  end

  def handle_params(_, _, socket) do
    default_server = select_default_server(socket.assigns.servers)
    chatrooms = select_chatrooms(default_server)

    {:noreply, assign(socket,
      selected_server: default_server,
      chatrooms: chatrooms,
      selected_chatroom: select_first_room(chatrooms)
    )}
  end

  def render(assigns) do
    ~L"""
      <div id="app">
        <%= live_component @socket, ServerListingComponent, servers: @servers, selected_server: @selected_server %>
        <div id="col-2" >
          <%= live_component @socket, ChatroomListingComponent, chatrooms: @chatrooms, selected_server: @selected_server, selected_chatroom: @selected_chatroom %>
          <%= live_component @socket, UserComponent, id: "user", user: @user %>
        </div>
        <%= live_component @socket, ChatroomComponent, selected_chatroom: @selected_chatroom %>
        <%= live_component @socket, UserListComponent %>
     </div>
    """
  end

  defp select_default_server(servers) do
    if servers == [], 
      do: select_null_server(), else: servers |> Enum.at(0)
  end

  defp select_chatrooms(server) do
      if server.name == :nil, 
        do: [], else: Chat.get_server_chatrooms(server)
  end

  defp select_first_room([]), do: select_null_chatroom() 
  defp select_first_room([head|_tail]), do: head

  defp select_null_chatroom(), do: %Chatroom{roomname: :nil} 

  defp select_null_server(), do: %Server{name: :nil} 

end
