defmodule WebchatWeb.InvitationController do
  use WebchatWeb, :controller

  def index(conn, params) do
    IO.inspect params
    render(conn, "invalid_invite.html")
  end

end
