defmodule ElmSimpleChat do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(ElmSimpleChat.Endpoint, []),
      worker(ElmSimpleChat.Storage.ETS, [])
    ]

    opts = [strategy: :one_for_one, name: ElmSimpleChat.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    ElmSimpleChat.Endpoint.config_change(changed, removed)
    :ok
  end
end
