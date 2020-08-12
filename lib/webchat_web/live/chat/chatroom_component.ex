defmodule WebchatWeb.Chat.Models.ChatroomComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
    <div
      id="chatroom" data-id="<%= @selected_chatroom.id %>"
    >
      <div id="name-container">
        <h1 id="chatroom-name"><%= @selected_chatroom.roomname %></h1>
      </div>
      <div id="messages-container" phx-update="ignore">
      </div>
      <div id="chatbox">
        <div id="msg-box">
          <textarea
            autofocus
            id="msg-input"
            placeholder="Message..."
            maxlength="500"
          ></textarea>
          <button id="msg-submit">
            Send
          </button>
        </div>
      </div>
    </div>
    """
  end

end
