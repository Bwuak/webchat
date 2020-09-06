defmodule WebchatWeb.Chat.ErrorComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
    <div class="page-container" > 
      <h3>ERROR</h3>
      </br>
      <p><%= @error %></p>
    </div>
    """
  end

end
