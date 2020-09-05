defmodule WebchatWeb.InvitationController do
  use WebchatWeb, :controller

  alias Webchat.Invitation
  alias Webchat.Invitation.Invites

  def index(conn, %{"id" => invitation_id}) do
    user = conn.assigns.current_user
    invite = Invites.get(invitation_id)

    cond do
      user && invite ->
        Invitation.redeem_invite(user, invite)
        conn 
        |> delete_session(:invite)
        |> redirect(to: "/chat?server_id=#{invite.server_id}")

      invite ->
        conn 
        |> put_session(:invite, invite)
        |> render("index.html")

      true ->
        conn
        |> render("invalid_invite.html")
    end
  end

end
