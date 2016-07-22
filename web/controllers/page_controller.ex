defmodule ElmSimpleChat.PageController do
  use ElmSimpleChat.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
