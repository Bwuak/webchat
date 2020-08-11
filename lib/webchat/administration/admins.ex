defmodule Webchat.Administration.Admins do
  import Ecto.Query, warn: false
  alias Webchat.Repo

  alias Webchat.Administration.Users.User
  alias Webchat.Administration.Admins.Admin

  def get_admin(%User{id: user_id}) do
    Repo.get_by(Admin, %{user_id: user_id})
  end

end
