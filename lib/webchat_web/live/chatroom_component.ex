defmodule ChatroomComponent do
  use Phoenix.LiveComponent


  def render(assigns) do
    ~L"""
    <div
      id="chatroom" data-id="<%= @chatroom.id %>"
    >
      <div id="name-container">
        <h1 id="chatroom-name"><%= @chatroom.roomname %></h1>
      </div>
      <div id="messages-container">
      </div>
      <div id="chatbox">
        <div id="msg-box">
          <textarea 
             autofocus
             id="msg-input"
             placeholder="Message..."
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