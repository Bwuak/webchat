defmodule WebchatWeb.Chat.Models.ChatroomComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
    <div
    id="chatroom" 
    
    >
      <div id="name-container">
        <h1 id="chatroom-name" phx-hook="Chatroom" data-id="<%= @selected_chatroom.id %>" ><%= @selected_chatroom.roomname %></h1>
      </div>
      <div id="messages-container" phx-update="ignore" >
      </div>
      <div id="chatbox">
        <div id="msg-box" >
          <textarea
            autofocus
            id="msg-input"
            placeholder="Message..."
            maxlength="500"
            phx-update="ignore"
          ></textarea>
          <button 
            id="msg-submit"
            >
            Send
          </button>
        </div>
      </div>
    </div>
    """
  end

end
