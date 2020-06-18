defmodule WebchatWeb.UserView do
  use WebchatWeb, :view

  def render("user.json", %{user: user}) do
    %{id: user.id, username: user.username}
  end

end
