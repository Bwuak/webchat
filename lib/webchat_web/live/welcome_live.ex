defmodule WebchatWeb.WelcomeLive do
  use WebchatWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <div id="welcome-container">
      <div>
        <button>
          Login
        </button>
        <button>
          Signup
        </button>
      </div>
      <%= live_component @socket, SignupComponent %> 
    </div>
    """
  end

end
