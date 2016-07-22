defmodule ElmSimpleChat.Message do

  defstruct id: "",
            key: "",
            from: "",
            to: "",
            body: ""

  @doc """
  create new message
  """
  def new(%{"from" => from, "to" => to, "body" => body})
  when bit_size(from) > 0
  and bit_size(to) > 0
  and bit_size(body) > 0
  do
    key = generate_key from, to
    id = generate_id(key)
    %__MODULE__ {
      id: id,
      key: key,
      from: from,
      to: to,
      body: body }
  end

  @doc """
  save message into ets table
  """
  def save(%__MODULE__{key: key} = model) do
    true = :ets.insert __MODULE__, {key, model}
  end

  @doc """
  get messages by key
  """
  def get(%{"from" => from, "to" => to}) do
    get from, to
  end
  def get(from, to) do
    key = generate_key(from, to)
    :ets.lookup(__MODULE__, key)
    |> Enum.map(fn {_key, val} -> val end)
    |> Enum.sort(&(&1.id > &2.id))
  end

  defp generate_key(_from, "lobby") do
    "lobby@lobby"
  end
  defp generate_key(from, to)
  when bit_size(from) > 0
  and bit_size(to) > 0 do
    [from, to]
    |> Enum.map(&String.downcase/1)
    |> Enum.sort
    |> Enum.join("@")
  end

  defp generate_id(key) when is_binary(key) do
    DateTime.utc_now
    |> DateTime.to_unix(:microseconds)
    |> to_string
    |> Kernel.<>(key)
  end


end
