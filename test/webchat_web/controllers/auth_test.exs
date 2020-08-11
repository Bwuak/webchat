defmodule WebchatWeb.AuthTest do
  use WebchatWeb.ConnCase, async: true

  alias WebchatWeb.Auth


  describe "testing authentication" do

    setup %{conn: conn} do
      conn = 
        conn
        |> bypass_through(WebchatWeb.Router, :browser)
        |> get("/")

      {:ok, %{conn: conn}}
    end

    test "Auth.authenticate_user/2 halts when no current_user exists", %{conn: conn} do
      conn =
        conn
        |> Auth.authenticate_user([])
      assert conn.halted
    end

    test "Auth.authenticate_user/2 is not halted for an existing current_user", %{conn: conn} do
      conn = 
        conn
        |> assign(:current_user, %Webchat.Administration.Users.User{})
        |> Auth.authenticate_user([])
      refute conn.halted
    end

    test "Auth.login/2 puts the user in the session", %{conn: conn} do
      login_conn =
        conn
        |> Auth.login(%Webchat.Administration.Users.User{id: 1})
        |> send_resp(:ok, "")
      next_conn = get(login_conn, "/")
      assert get_session(next_conn, :user_id) == 1
    end

    test "Auth.logout/1 removes the session", %{conn: conn} do
      logout_conn =
        conn
        |> put_session(:user_id, 1)
        |> Auth.logout()
        |> send_resp(:ok, "")
      next_conn = get(logout_conn, "/")
      refute get_session(next_conn, :user_id)
    end

    test "Auth.call/2 auth plug call places user from session into assigns", %{conn: conn} do
      user = user_fixture()
      conn =
        conn
        |> put_session(:user_id, user.id)
        |> Auth.call(Auth.init([]))
      assert conn.assigns.current_user.id == user.id
    end

    test "Auth.call/2 with no sessions sets current_user assign to nil", %{conn: conn} do
      conn = Auth.call(conn, Auth.init([]))
      assert conn.assigns.current_user == nil
    end

  end

end
