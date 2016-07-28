defmodule ElmSimpleChat.UserTest do
  use ExUnit.Case, async: true

  alias ElmSimpleChat.User

  test "API join should add user in Users Tab" do
    1 = User.join("hawk")
    [{"hawk", %User{name: "hawk"}, 1}] = :ets.lookup User, "hawk"
  end

  test "API join should not duplicated users in Users Tab" do
    1 = User.join("tommy")
    2 = User.join("tommy")
    [{"tommy", %User{name: "tommy"}, 2}] = :ets.lookup User, "tommy"
  end

  test "API leave should remove users from Users Tab" do
    User.join("ark")
    User.join("ark")
    1 = User.leave("ark")
    [{"ark", %User{name: "ark"}, 1}] = :ets.lookup User, "ark"
    0 = User.leave("ark")
    [] = :ets.lookup User, "ark"
  end

  test "API get_users should return all users in Users Tab" do
    :ets.delete_all_objects User
    1 = User.join("som-o")
    1 = User.join("durian")
    1 = User.join("mango")
    users = User.get_users
    assert length(users) == 3
    assert %User{name: "som-o", state: "online"} in users
    assert %User{name: "durian", state: "online"} in users
    assert %User{name: "mango", state: "online"} in users
  end

end
