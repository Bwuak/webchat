defmodule WebchatWeb.ChatLive do
  use WebchatWeb, :live_view

  alias Webchat.Accounts
  alias Webchat.Chat
  alias Webchat.Chat.Server
  alias Webchat.Chat.Chatroom


  def mount(_params, session, socket) do
    user = Accounts.get_user!(session["user_id"])
    servers = Chat.list_servers()

    {:ok, 
      assign(socket, 
      servers: servers,
      user: user
      ),
      layout: {WebchatWeb.LayoutView, "chat_live.html"}
    }
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
    selected_server = String.to_integer(sid) |> Chat.get_server()
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
    <%= if Map.has_key?(assigns, :action) do %>
      <div class="server-action">
        <%= render_action_component(assigns) %>
      </div>
    <% end %>
    """
  end

  def handle_event("cancel_action", _, socket) do
    socket_without_action = 
      %{ socket |
        assigns: Map.delete(socket.assigns, :action), 
        changed: Map.put_new(socket.changed, :action, true)
      } 

    {:noreply, socket_without_action} 
  end

  def handle_event("server-action", _, socket) do
    {:noreply, assign(socket, action: "")}
  end

  def render_action_component(_assigns) do
    "Get component -> logic here"
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
