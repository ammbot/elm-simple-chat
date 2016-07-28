defmodule ElmSimpleChat.RoomChannel do
  use ElmSimpleChat.Web, :channel

  alias Phoenix.Socket.Broadcast
  alias ElmSimpleChat.Endpoint
  alias ElmSimpleChat.{User, Message}

  def join("room:lobby", payload, socket) do
    if authorized?(payload) do
      User.join payload["name"]
      new_socket = assign(socket, :name, payload["name"])
      put_private_channel(new_socket)
      rooms = get_rooms(new_socket)
      {:ok, %{rooms: rooms}, new_socket}
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
  def handle_in("shout", %{"to" => "room:lobby"} = payload, socket) do
    payload = Map.put(payload, "to", "lobby") |> Message.new
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

  def handle_info(%Broadcast{topic: _, event: "private", payload: payload}, socket) do
    payload = Message.new payload
    push socket, "private", payload
    {:noreply, socket}
  end

  def handle_info(_msg, socket) do
    {:noreply, socket}
  end

  def terminate(_reason, socket) do
    User.leave socket.assigns.name
  end

  # Add authorization logic here as required.
  defp authorized?(%{"name" => name}) when bit_size(name) > 0 do
    true
  end
  defp authorized?(_payload) do
    false
  end

  defp put_private_channel(%{assigns: %{name: name}}) do
    :ok = Endpoint.subscribe("room:" <> name)
  end

  # get rooms for user.
  # from online users and historic chat rooms
  defp get_rooms(socket) do
    online = User.get_users
    online_name = Enum.map(online, &(&1.name)) |> MapSet.new
    messages = Message.get(socket.assigns.name)
    users_from_messages =
      Enum.map(messages, &[&1.from, &1.to])
      |> List.flatten
      |> MapSet.new
      |> MapSet.delete("lobby")
    offline =
      MapSet.difference(users_from_messages, online_name)
      |> Enum.map(&%User{name: &1, state: "offline"})
    online ++ offline ++ [%User{name: "lobby", state: "online"}]
  end

end
