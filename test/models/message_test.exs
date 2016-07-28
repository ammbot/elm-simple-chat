defmodule ElmSimpleChat.MessageTest do
  use ExUnit.Case, async: true

  import ElmSimpleChat.TestHelper
  alias ElmSimpleChat.Storage.ETS
  alias ElmSimpleChat.Message

  require Logger

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

  test "API get messages by user should return only involved messages and lobby" do
    :ets.delete_all_objects Message
    create_message("gane", "jay", "hoola") |> Message.save
    create_message("jay", "gane", ":>") |> Message.save
    create_message("gane", "rye", "aha") |> Message.save
    create_message("jay", "lobby", "welcome") |> Message.save
    create_message("rye", "jay", "secret") |> Message.save
    msgs = Message.get("gane")
    assert length(msgs) == 4
    [%Message{body: "welcome"},
     %Message{body: "aha"},
     %Message{body: ":>"},
     %Message{body: "hoola"}] = msgs
  end

  test "table message should flushed to disk 1 second after updated" do
    file =
      :elm_simple_chat
      |> Application.get_env(ETS)
      |> Keyword.get(:messages_file)
    File.rm file

    create_message("H", "O", "luego") |> Message.save
    Process.sleep 1000
    assert File.exists?(file) == true
  end

end
