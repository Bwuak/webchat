defmodule WebchatWeb.TestLive do
  use WebchatWeb, :live_view


  def mount(_params, _session, socket) do
    socket = assign(socket, bob: "bob")
    IO.inspect socket
    {:ok, socket} 
  end

  def render(assigns) do
    ~L"""
    <h1>Hello</h1>
    """
  end


end
