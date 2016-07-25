defmodule ElmSimpleChat.User do
  defstruct name: ""
  require Logger

  @doc """
  join, add user into ets table
  """
  def join(user) when is_binary(user) do
    join %__MODULE__{name: user}
  end
  def join(%__MODULE__{name: name} = model) do
    true = :ets.insert __MODULE__, {name, model}
  end

  @doc """
  leave, delete user from ets table
  """
  def leave(user) when is_binary(user) do
    leave %__MODULE__{name: user}
  end
  def leave(%__MODULE__{name: name}) do
    true = :ets.delete __MODULE__, name
  end

  @doc """
  get all users from ets table
  """
  def get_users do
    __MODULE__
    |> :ets.first
    |> get_users([])
    |> Enum.map(&%__MODULE__{name: &1})
  end

  defp get_users(:'$end_of_table', acc) do
    acc
  end
  defp get_users(key, acc) do
    new_key = :ets.next __MODULE__, key
    get_users new_key, [key|acc]
  end

end
