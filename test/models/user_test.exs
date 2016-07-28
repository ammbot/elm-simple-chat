defmodule ElmSimpleChat.UserTest do
  use ExUnit.Case, async: true

  alias ElmSimpleChat.User

  test "API join should add user in Users Tab" do
    true = User.join("hawk")
    [{"hawk", %User{name: "hawk"}}] = :ets.lookup User, "hawk"
  end

  test "API join should not duplicated users in Users Tab" do
    true = User.join("tommy")
    true = User.join("tommy")
    [{"tommy", %User{name: "tommy"}}] = :ets.lookup User, "tommy"
  end

  test "API leave should remove users from Users Tab" do
    true = User.leave("ark")
    [] = :ets.lookup User, "ark"
  end

  test "API get_users should return all users in Users Tab" do
    :ets.delete_all_objects User
    true = User.join("som-o")
    true = User.join("durian")
    true = User.join("mango")
    users = User.get_users
    assert length(users) == 3
    assert %User{name: "som-o", state: "online"} in users
    assert %User{name: "durian", state: "online"} in users
    assert %User{name: "mango", state: "online"} in users
  end

end
