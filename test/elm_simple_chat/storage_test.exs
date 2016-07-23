defmodule ElmSimpleChat.StorageTest do
  use ExUnit.Case, async: false

  alias ElmSimpleChat.Storage
  alias ElmSimpleChat.{User, Message}

  defp create_message(from, to, body) do
    Message.new %{"body" => body, "from" => from, "to" => to}
  end

  test "should init table ElmSimpleChat.Users" do
    tab = :ets.info User
    assert tab != :undefined
    assert tab[:read_concurrency] == true
    assert tab[:write_concurrency] == true
    assert tab[:named_table] == true
    assert tab[:type] == :set
  end

  test "should init table ElmSimpleChat.Message" do
    tab = :ets.info Message
    assert tab != :undefined
    assert tab[:read_concurrency] == true
    assert tab[:write_concurrency] == true
    assert tab[:named_table] == true
    assert tab[:type] == :bag
  end

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
    assert {"som-o", %User{name: "som-o"}} in users
    assert {"durian", %User{name: "durian"}} in users
    assert {"mango", %User{name: "mango"}} in users
  end

  test "API new_message produce model" do
    model = Message.new %{"body" => "hello", "from" => "A", "to" => "B"}
    %Message{body: "hello", from: "A", to: "B", id: _, key: "a@b"} = model
  end

  test "API new_message to lobby will produce key as lobby@lobby" do
    model = Message.new %{"body" => "hi", "from" => "A", "to" => "lobby"}
    %Message{body: "hi", from: "A", to: "lobby", id: _, key: "lobby@lobby"} = model
  end

  test "API new_message should insert message into Messages Tab" do
    msg = create_message "A", "B", "hola"
    true = Message.save msg
  end

  test "API new_message should not duplicated (key)" do
    :ets.delete_all_objects Message
    msg = create_message "A", "B", "nueva"
    true = Message.save msg
    true = Message.save msg
    true = Message.save msg
    [{"a@b", %Message{}}] = :ets.lookup Message, "a@b"
  end

  test "API get messages should get all messages from room (key)" <>
       " and sorted by id" do
    :ets.delete_all_objects Message
    create_message("A", "C", "bonita") |> Message.save
    create_message("C", "A", "gracias") |> Message.save
    create_message("A", "lobby", "hola") |> Message.save
    msgs = Message.get("a", "c")
    ^msgs = Message.get("c", "a")
    assert length(msgs) == 2
    [%Message{body: "gracias"}, %Message{body: "bonita"}] = msgs

    msgs = Message.get("lobby", "lobby")
    assert length(msgs) == 1
    [%Message{body: "hola"}] = msgs
  end

  test "table message should flushed to disk 1 second after updated" do
    file =
      :elm_simple_chat
      |> Application.get_env(Storage.ETS)
      |> Keyword.get(:messages_file)
    File.rm file

    create_message("H", "O", "luego") |> Message.save
    Process.sleep 1000
    assert File.exists?(file) == true

    :ets.delete Message
    assert :ets.info Message == :undefined

    assert :ets.file2tab(file) == {:ok, Message}
    [%Message{from: "H", to: "O", body: "luego"}] =
      Message.get("H", "O")
  end

end
