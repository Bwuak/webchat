defmodule Webchat.Chat.RolesTest do
  use Webchat.DataCase, async: true

  alias Webchat.Repo
  alias Webchat.Chat.Models.Role
  alias Webchat.Chat.Roles


  setup do
    roles_setup()
  end

  test "get! member role struct" do
    role = Roles.get!("member")

    %Role{} = role 
    assert role.name == "member"
  end

  test "get! banned role struct" do
    role = Roles.get!("banned")

    %Role{} = role 
    assert role.name == "banned"
  end

  @invalid_name "unexisting role name"
  test "get!/1 error when invalid role" do
    assert_raise RuntimeError, fn -> Roles.get!(@invalid_name) end
  end

  # same as test helpers
  @roles_names [
    "banned",
    "member"
  ]
  test "roles structs compared to db role data" do
    for role_name <- @roles_names do
      role = Roles.get!(role_name)
      assert role.name == Repo.get!(Role, role_name).name
    end
  end

end
