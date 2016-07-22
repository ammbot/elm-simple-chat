use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :elm_simple_chat, ElmSimpleChat.Endpoint,
  http: [port: 4001],
  server: false

config :elm_simple_chat, ElmSimpleChat.Storage.ETS,
  messages_file: 'messages_test.dat'

# Print only warnings and errors during test
config :logger, level: :warn
