defmodule WebchatWeb.PageController do
  use WebchatWeb, :controller

  def index(conn, _params) do
    case conn.assigns.current_user do
      nil ->
        render(conn, "index.html")

      _connected_user ->
        conn
        |> redirect(to: "/chat") 
    end 
  end

end
