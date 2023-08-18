# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :basic_phx_app,
  ecto_repos: [BasicPhxApp.Repo]

# Configures the endpoint
config :basic_phx_app, BasicPhxAppWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: BasicPhxAppWeb.ErrorHTML, json: BasicPhxAppWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: BasicPhxApp.PubSub,
  live_view: [signing_salt: "xkx+JVKl"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :basic_phx_app, BasicPhxApp.Mailer, adapter: Swoosh.Adapters.Local

config :swoosh, :api_client, false

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.2.7",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

case config_env() do
  :prod ->
    # Note we also include the path to a cache manifest
    # containing the digested version of static files. This
    # manifest is generated by the `mix assets.deploy` task,
    # which you should run after static files are built and
    # before starting your production server.
    config :basic_phx_app, BasicPhxAppWeb.Endpoint,
      cache_static_manifest: "priv/static/cache_manifest.json"

    # Configures Swoosh API Client
    config :swoosh, api_client: Swoosh.ApiClient.Finch, finch_name: BasicPhxApp.Finch

    # Do not print debug messages in production
    config :logger, level: :info

  # Runtime production configuration, including reading
  # of environment variables, is done on config/runtime.exs.

  :dev ->
    # Configure your database
    config :basic_phx_app, BasicPhxApp.Repo,
      stacktrace: true,
      show_sensitive_data_on_connection_error: true

    # For development, we disable any cache and enable
    # debugging and code reloading.
    #
    # The watchers configuration can be used to run external
    # watchers to your application. For example, we can use it
    # to bundle .js and .css sources.
    config :basic_phx_app, BasicPhxAppWeb.Endpoint,
      # Binding to loopback ipv4 address prevents access from other machines.
      # Change to `ip: {0, 0, 0, 0}` to allow access from other machines.
      http: [ip: {127, 0, 0, 1}, port: 4000],
      check_origin: false,
      code_reloader: true,
      debug_errors: true,
      secret_key_base: "/iH83a2apFtja+dSBcRzO45lIj2HbOx7sELzem6qKPhFKKVWXC2WVlZUN8/ovI1V",
      watchers: [
        esbuild: {Esbuild, :install_and_run, [:default, ~w(--sourcemap=inline --watch)]},
        tailwind: {Tailwind, :install_and_run, [:default, ~w(--watch)]}
      ],
      live_reload: [
        patterns: [
          ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
          ~r"priv/gettext/.*(po)$",
          ~r"lib/basic_phx_app_web/(controllers|live|components)/.*(ex|heex)$"
        ]
      ]

    # Enable dev routes for dashboard and mailbox
    config :basic_phx_app, dev_routes: true

    # Do not include metadata nor timestamps in development logs
    config :logger, :console, format: "[$level] $message\n"

    # Set a higher stacktrace during development. Avoid configuring such
    # in production as building large stacktraces may be expensive.
    config :phoenix, :stacktrace_depth, 20

    # Initialize plugs at runtime for faster development compilation
    config :phoenix, :plug_init_mode, :runtime

  :test ->
    # Configure your database
    #
    # The MIX_TEST_PARTITION environment variable can be used
    # to provide built-in test partitioning in CI environment.
    # Run `mix help test` for more information.
    config :basic_phx_app, BasicPhxApp.Repo,
      stacktrace: true,
      show_sensitive_data_on_connection_error: true,
      pool: Ecto.Adapters.SQL.Sandbox

    # We don't run a server during test. If one is required,
    # you can enable the server option below.
    config :basic_phx_app, BasicPhxAppWeb.Endpoint,
      http: [ip: {127, 0, 0, 1}, port: 4002],
      secret_key_base: "jXZgjM7IafimU1wE2vX9QOiUZEBOz6QSH08ip5lBFVUZiyNiV/m3tsbS7mxdXUi5",
      server: false

    # In test we don't send emails.
    config :basic_phx_app, BasicPhxApp.Mailer, adapter: Swoosh.Adapters.Test

    # Disable swoosh api client as it is only required for production adapters.
    config :swoosh, :api_client, false

    # Print only warnings and errors during test
    config :logger, level: :warning

    # Initialize plugs at runtime for faster test compilation
    config :phoenix, :plug_init_mode, :runtime
end