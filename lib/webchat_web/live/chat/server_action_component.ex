defmodule WebchatWeb.Chat.ServerActionComponent do
  use Phoenix.LiveComponent
  use Phoenix.HTML


  def render(assigns) do
    ~L"""
    <div>
      <p>Join or Create a server</p>
      <button phx-click="join-server" > 
        Join
      </button>
      <button phx-click="create-server" >
        Create
      </button>
    </div>
    """
  end

end
