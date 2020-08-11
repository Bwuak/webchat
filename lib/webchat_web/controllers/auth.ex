defmodule WebchatWeb.Auth do
  import Phoenix.Controller
  import Plug.Conn

  alias WebchatWeb.Router.Helpers, as: Routes

  def init(opts), do: opts

  # If user
  # put user information in connection
  # else
  # current user is nil
  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)

    cond do
      user = conn.assigns[:current_user] ->
        put_current_user(conn, user)

      user = user_id && Webchat.Administration.Users.get_user(user_id) ->
        put_current_user(conn, user)

      true -> 
        assign(conn, :current_user, nil)
    end
  end
  
  # Assign 
  # Current user session to the connection
  # user token for websocket identification
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
    |> configure_session(renew: true)
  end

  def logout(conn) do
    configure_session(conn, drop: true)
  end


  # If user 
  # Return connection
  # Else
  # Redirect a non connected user to welcome page and stop other plugs
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
