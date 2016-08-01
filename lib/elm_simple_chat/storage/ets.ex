defmodule ElmSimpleChat.Storage.ETS do
  use GenServer
  alias ElmSimpleChat.Storage
  alias ElmSimpleChat.{User, Message}
  require Logger

  defmodule State do
    defstruct tab: nil, file: nil
  end

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
    {:ok, %State{}}
  end

  def flush(Message) do
    GenServer.call Storage, {:flush, Message, conf[:messages_file]}
  end

  def handle_call({:flush, tab, file}, _from, %State{tab: nil}) when is_list(file) do
    Process.send_after self, :flush, 1000
    {:reply, :ok, %State{tab: tab, file: file}}
  end
  def handle_call({:flush, _tab, _file}, _from, %State{} = state) do
    {:reply, :ok, state}
  end

  def handle_info(:flush, %State{tab: tab, file: file}) do
    tab |> :ets.tab2file(file)
    {:noreply, %State{}}
  end

  defp init_users_table do
    tab = :ets.new User, @opts ++ [:set]
    {:ok, tab}
  end

  defp init_messages_table do
    with file when is_list(file) <- conf[:messages_file],
         true <- File.exists?(file) do
      :ets.file2tab(file)
    else
      false ->
        tab = :ets.new Message, @opts ++ [:bag]
        {:ok, tab}
      nil ->
        raise __MODULE__, "no messages_file found in config"

    end
  end

  defp conf do
    :elm_simple_chat |> Application.get_env(__MODULE__)
  end

end
