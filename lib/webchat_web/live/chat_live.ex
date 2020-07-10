defmodule WebchatWeb.ChatLive do
  use WebchatWeb, :live_view

  alias Webchat.Chat
  alias Webchat.Chat.Chatroom
  alias WebchatWeb.Chat.{
    ChatroomComponent,
    UserListComponent,
    ChatroomListingComponent,
    ServerListingComponent,
    UserComponent
  }


  def mount(_params, _session, socket) do
    servers = Chat.list_servers()
    {:ok, assign(socket, servers: servers)}
  end

  def handle_params(%{"server_id" => sid, "room_id" => rid}, _url, socket) do
    selected_server = String.to_integer(sid) |> Chat.get_server!()
    chatrooms = Chat.get_server_chatrooms(selected_server)
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
    chatrooms = Chat.get_server_chatrooms(selected_server)
    default_chatroom = select_first_room(chatrooms)

    {:noreply, assign(socket,
      selected_server: selected_server,
      chatrooms: chatrooms,
      selected_chatroom: default_chatroom
      )}
  end

  def handle_params(_, _, socket) do
    default_server = socket.assigns.servers |> Enum.at(0)
    chatrooms = Chat.get_server_chatrooms(default_server)
    default_chatroom = select_first_room(chatrooms)

    {:noreply, assign(socket,
      selected_server: default_server,
      chatrooms: chatrooms,
      selected_chatroom: default_chatroom
    )}
  end

  def render(assigns) do
    ~L"""
      <div id="app">
        <%= live_component @socket, ServerListingComponent, servers: @servers, selected_server: @selected_server %>
        <div>
          <%= live_component @socket, ChatroomListingComponent, chatrooms: @chatrooms, selected_server: @selected_server, selected_chatroom: @selected_chatroom %>
          <%= live_component @socket, UserComponent %>
        </div>
        <%= live_component @socket, ChatroomComponent, selected_chatroom: @selected_chatroom %>
        <%= live_component @socket, UserListComponent %>
     </div>
    """
  end

  defp select_first_room([]), do: %Chatroom{roomname: "NO ROOM IN THIS SERVER YET"}
  defp select_first_room([head|_tail]), do: head
end
