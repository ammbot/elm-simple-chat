defmodule ElmSimpleChat.Storage.ETS do
  use GenServer
  alias ElmSimpleChat.Storage
  alias ElmSimpleChat.{User, Message}

  defexception message: "error"
  
  @opts [
    :public,
    :named_table,
    {:read_concurrency, true},
    {:write_concurrency, true}
  ]

  def start_link do
    GenServer.start_link __MODULE__, [], name: Storage
  end

  def init(_) do
    {:ok, _tab} = init_users_table
    {:ok, _tab} = init_messages_table
    {:ok, nil}
  end

  defp init_users_table do
    with file when is_list(file) <- conf[:messages_file],
         true <- File.exists?(file) do
      :ets.file2tab(file)
    else
      false ->
        tab = :ets.new User, @opts ++ [:set]
        {:ok, tab}
      nil ->
        raise __MODULE__, "no messages_file found in config"

    end
  end

  defp init_messages_table do
    tab = :ets.new Message, @opts ++ [:bag]
    {:ok, tab}
  end

  defp conf do
    :elm_simple_chat |> Application.get_env(__MODULE__)
  end

end
