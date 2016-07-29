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
      send self, :after_join
      {:ok, new_socket}
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
    {:stop, :normal, socket}
  end

  def handle_in(_event, _payload, socket) do
    {:reply, {:error, %{"msg" => "invalid request"}}, socket}
  end

  def handle_info(:after_join, socket) do
    rooms = get_rooms(socket)
    push socket, "rooms", %{rooms: rooms}
    payload = %User{name: socket.assigns.name, state: "online"}
    broadcast_from socket, "presence", payload
    {:noreply, socket}
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
    counter = User.leave socket.assigns.name
    if counter <= 0 do
      payload = %User{name: socket.assigns.name, state: "offline"}
      broadcast_from socket, "presence", payload
    end
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
  # rooms will not included self
  defp get_rooms(socket) do
    me = socket.assigns.name
    online_name =
      User.get_users
      |> Enum.map(&(&1.name))
      |> List.insert_at(-1, "lobby")
    me
    |> Message.get
    |> Enum.group_by(fn message ->
      cond do
        message.to == "lobby" -> message.to
        message.from == me -> message.to
        message.to == me -> message.from
      end
    end)
    |> Enum.map(fn {key, messages} ->
      state = if key in online_name, do: "online", else: "offline"
      %{"room" => %User{name: key, state: state},
        "messages" => messages}
    end)
  end

end
