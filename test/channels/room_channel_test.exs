defmodule ElmSimpleChat.RoomChannelTest do
  use ElmSimpleChat.ChannelCase

  import ElmSimpleChat.TestHelper
  alias ElmSimpleChat.Endpoint
  alias ElmSimpleChat.{User, Message}
  alias ElmSimpleChat.RoomChannel

  setup do
    :ets.delete_all_objects Message
    create_message("admin", "system", "welcome") |> Message.save
    create_message("admin", "lobby", "welcome") |> Message.save
    create_message("someone", "happy", "welcome") |> Message.save
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
    assert %User{name: "someone", state: "online"} in User.get_users
  end

  test "join broadcast presence to room:lobby" do
    {:ok, _, _} =
      socket("user_id", %{some: :assign})
      |> subscribe_and_join(RoomChannel, "room:lobby", %{"name" => "polka"})
    assert_broadcast "presence", %User{name: "polka", state: "online"}
  end

  test "join will got rooms event for current online users" <>
       "and chat history that we had. list will not included self" do
    assert_push "rooms", %{rooms: rooms}
    names = Enum.map(rooms, &(&1["room"]))
    assert length(names) == 2
    assert %User{name: "lobby", state: "online"} in names
    assert %User{name: "happy", state: "offline"} in names
    lobby_idx = Enum.find_index(rooms, fn(r) -> r["room"].name == "lobby" end)
    Enum.each((Enum.at rooms, lobby_idx)["messages"], fn(m) -> assert m.to == "lobby" end)
    happy_idx = Enum.find_index(rooms, fn(r) -> r["room"].name == "happy" end)
    [%Message{to: "happy"}] = (Enum.at rooms, happy_idx)["messages"]
  end

  test "leave make client teminated and call User.leave" do
    Process.flag :trap_exit, true
    {:ok, _, socket} =
      socket("user_id", %{some: :assign})
      |> subscribe_and_join(RoomChannel, "room:lobby", %{"name" => "it's me"})
    assert %User{name: "it's me", state: "online"} in User.get_users
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

  test "push to private channel" do
    Endpoint.broadcast("room:someone",  "private",
     %{"from" => "me", "to" => "someone", "body" => "hey"})
    assert_push "private", %Message{from: "me", to: "someone", body: "hey"}
  end

end
