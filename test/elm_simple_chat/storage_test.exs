defmodule ElmSimpleChat.StorageTest do
  use ExUnit.Case, async: true

  alias ElmSimpleChat.{User, Message}

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

end
