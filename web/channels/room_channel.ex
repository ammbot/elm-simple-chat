defmodule ElmSimpleChat.RoomChannel do
  use ElmSimpleChat.Web, :channel

  alias ElmSimpleChat.{User, Message}

  require Logger

  def join("room:lobby", payload, socket) do
    if authorized?(payload) do
      User.join payload["name"]
      {:ok, assign(socket, :name, payload["name"])}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (room:lobby).
  def handle_in("shout", %{"to" => "room:" <> room} = payload, socket) do
    payload = Map.put(payload, "to", room) |> Message.new
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  def handle_in("leave", _payload, socket) do
    User.leave socket.assigns.name
    {:stop, :normal, socket}
  end

  def handle_in(_event, _payload, socket) do
    {:reply, {:error, %{"msg" => "invalid request"}}, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(%{"name" => name}) when bit_size(name) > 0 do
    true
  end
  defp authorized?(_payload) do
    false
  end

end
