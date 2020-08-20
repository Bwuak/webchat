defmodule Webchat.Administration.Admins do
  import Ecto.Query, warn: false
  alias Webchat.Repo

  alias Webchat.Administration.Models.Admin


  def get_by(params), do: Repo.get_by(Admin, params)
end
