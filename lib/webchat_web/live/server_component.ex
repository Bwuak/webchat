defmodule ServerComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
    <div>
      <%= for room <- @chatrooms do %>
        <h1><%= room.roomname %></h1>
      <% end %>
    </div>
    """
  end
end
