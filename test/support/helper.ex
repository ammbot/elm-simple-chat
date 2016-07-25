defmodule ElmSimpleChat.TestHelper do

  alias ElmSimpleChat.Message

  def create_message(from, to, body) do
    Message.new %{"body" => body, "from" => from, "to" => to}
  end

end
