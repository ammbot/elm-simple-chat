defmodule ElmSimpleChat.User do
  defstruct name: "", state: "offline"
  require Logger

  @doc """
  join, add user into ets table
  """
  def join(user) when is_binary(user) do
    join %__MODULE__{name: user}
  end
  def join(%__MODULE__{name: name} = model) do
    :ets.update_counter __MODULE__, name, {3, 1}, {name, model, 0}
  end

  @doc """
  leave, delete user from ets table
  """
  def leave(user) when is_binary(user) do
    leave %__MODULE__{name: user}
  end
  def leave(%__MODULE__{name: name} = model) do
    counter = :ets.update_counter __MODULE__, name, {3, -1}, {name, model, 1}
    case counter do
      n when n <= 0 ->
        :ets.delete __MODULE__, name
        0
      m -> m
    end
  end

  @doc """
  get all users from ets table
  """
  def get_users do
    __MODULE__
    |> :ets.first
    |> get_users([])
    |> Enum.map(&%__MODULE__{name: &1, state: "online"})
  end

  defp get_users(:'$end_of_table', acc) do
    acc
  end
  defp get_users(key, acc) do
    new_key = :ets.next __MODULE__, key
    get_users new_key, [key|acc]
  end

end
