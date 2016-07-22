# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :elm_simple_chat, ElmSimpleChat.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "pCnGZEdoAv61i3vmIzSP8ReJ20NPCoEeDVYBgc67I1KV7h0rujfwxBHnBw65FHzV",
  render_errors: [view: ElmSimpleChat.ErrorView, accepts: ~w(html json)],
  pubsub: [name: ElmSimpleChat.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :elm_simple_chat, ElmSimpleChat.Storage.ETS,
  messages_file: 'messages.dat'

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
