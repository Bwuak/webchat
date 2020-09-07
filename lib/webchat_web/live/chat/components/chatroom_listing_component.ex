defmodule WebchatWeb.Chat.ChatroomListingComponent do
  use Phoenix.LiveComponent 

  alias WebchatWeb.Router.Helpers, as: Routes


  def render(assigns) do
   ~L"""
    <div id="server" >
      <%= if @selected_server.user_id && @selected_server.user_id == @user.id do %>
      <div id="invite">
        <p phx-click="invite-menu">Invite +</p>
      </div>
        <% end %>
      <h3>Rooms</h3>
      <nav>
        <%= for room <- @chatrooms do %>
          <div>
            <%= live_patch room.roomname,
              to: Routes.live_path(
                @socket,
                WebchatWeb.ChatLive,
                server_id: @selected_server.id,
                room_id: room.id
              ),
              class: "room-link",
              class: if room == @selected_chatroom, do: "active-chatroom room-link"
            %>
          </div>
        <% end %>
        <div phx-click="create-room" class="room-link" >Create</div>
      </nav>
    </div>
    """
  end 

end
