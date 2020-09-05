defmodule WebchatWeb.Auth do
  import Phoenix.Controller
  import Plug.Conn

  alias WebchatWeb.Router.Helpers, as: Routes

  alias Webchat.Invitation
  alias Webchat.Invitation.Models.Invite

  def init(opts), do: opts

  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)

    cond do
      user = conn.assigns[:current_user] ->
        put_current_user(conn, user)

      user = user_id && Webchat.Administration.Users.get(user_id) ->
        put_current_user(conn, user)

      true ->
        assign(conn, :current_user, nil)
    end
  end

  # Creates token
  def put_current_user(conn, user) do
    token = Phoenix.Token.sign(conn, "user socket", user.id)

    conn
    |> assign(:current_user, user)
    |> assign(:user_token, token)
  end

  def login(conn, user) do
    conn
    |> assign(:current_user, user)
    |> put_session(:user_id, user.id)
    |> redeem_invites()
    |> put_session(:live_socket_id, "users_socket: #{user.id}")
    |> configure_session(renew: true)
  end

  # Fetch invites in session
  def redeem_invites(conn) do
    case get_session(conn, :invite) do 
      nil ->
        conn

      invite = %Invite{} ->
        Invitation.redeem_invite(conn.assigns.current_user, invite)
        conn 
        |> delete_session(:invite)

      _ ->
        conn
    end
  end


  def logout(conn) do
    configure_session(conn, drop: true)
  end


  # Validate a user is logged in
  def authenticate_user(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access that page")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt()
    end
  end

  def authenticate_admin(conn, _opts) do
    user = conn.assigns.current_user

    case Webchat.Administration.is_admin?(user) do
      true ->
        conn
      _ ->
        conn
        |> redirect(to: "/chat")
        |> halt()
    end
  end

end
