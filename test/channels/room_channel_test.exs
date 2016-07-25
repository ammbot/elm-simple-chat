defmodule ElmSimpleChat.RoomChannelTest do
  use ElmSimpleChat.ChannelCase

  alias ElmSimpleChat.{User, Message}
  alias ElmSimpleChat.RoomChannel

  require Logger

  setup do
    {:ok, _, socket} =
      socket("user_id", %{some: :assign})
      |> subscribe_and_join(RoomChannel, "room:lobby", %{"name" => "someone"})

    {:ok, socket: socket}
  end

  test "join has to sent name as a payload" do
    {:error, %{reason: "unauthorized"}} =
      socket
      |> subscribe_and_join(RoomChannel, "room:lobby")
  end

  test "join assign name in state", %{socket: socket} do
    assert socket.assigns.name == "someone"
  end

  test "join call User.join" do
    assert %User{name: "someone"} in User.get_users
  end

  test "leave make client teminated and call User.leave" do
    Process.flag :trap_exit, true
    {:ok, _, socket} =
      socket("user_id", %{some: :assign})
      |> subscribe_and_join(RoomChannel, "room:lobby", %{"name" => "it's me"})
    assert %User{name: "it's me"} in User.get_users
    push socket, "leave", %{}
    assert_receive {:EXIT, _, :normal}
    refute %User{name: "it's me"} in User.get_users
  end

  test "ping replies with status ok", %{socket: socket} do
    ref = push socket, "ping", %{"hello" => "there"}
    assert_reply ref, :ok, %{"hello" => "there"}
  end

  test "shout broadcasts to room:lobby", %{socket: socket} do
    push socket, "shout", %{"from" => "me", "to" => "room:lobby", "body" => "hello"}
    assert_broadcast "shout", %Message{to: "lobby"}
  end

  test "shout broadcasts to without room prefix", %{socket: socket} do
    ref = push socket, "shout", %{"from" => "me", "to" => "lobby", "body" => "hello"}
    assert_reply ref, :error, %{"msg" => "invalid request" }
    refute_broadcast "shout", _
  end

  test "broadcasts are pushed to the client", %{socket: socket} do
    broadcast_from! socket, "broadcast", %{"some" => "data"}
    assert_push "broadcast", %{"some" => "data"}
  end
end
