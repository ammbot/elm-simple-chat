defmodule ElmSimpleChat.Message do

  alias ElmSimpleChat.Storage.ETS

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
    ETS.flush __MODULE__
    true
  end

  @doc """
  get messages by user no matter he is sender or receiver
  """
  def get(user) when is_binary(user) do
    pattern = {:'$1', %__MODULE__{
      id: :'$4', key: :'$5', body: :'$6', from: :'$2', to: :'$3'}}
    result = [[:'$2', :'$3', :'$4', :'$5', :'$6']]
    spec = [
      {pattern, [{:'==', :'$2', user}], result},
      {pattern, [{:'==', :'$3', user}], result},
      {pattern, [{:'==', :'$3', "lobby"}], result}
     ]
    :ets.select(__MODULE__, spec)
    |> Enum.map(fn [from, to, id, key, body] ->
      %__MODULE__{from: from, to: to, id: id, key: key, body: body}
    end)
    |> sort_latest
  end

  @doc """
  get messages by key, combination of sender and receiver
  """
  def get(%{"from" => from, "to" => to}) do
    get from, to
  end
  def get(from, to) do
    key = generate_key(from, to)
    :ets.lookup(__MODULE__, key)
    |> Enum.map(fn {_key, val} -> val end)
    |> sort_latest
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

  defp sort_latest(list) do
    list |> Enum.sort(&(&1.id > &2.id))
  end


end
