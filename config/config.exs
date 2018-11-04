# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :asciinema,
  ecto_repos: [Asciinema.Repo]

# Configures the endpoint
config :asciinema, AsciinemaWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  render_errors: [view: AsciinemaWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Asciinema.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :template_engines,
  md: PhoenixMarkdown.Engine

config :sentry,
  dsn: "https://public:secret@sentry.io/1",
  environment_name: Mix.env,
  enable_source_code_context: true,
  root_source_code_path: File.cwd!,
  included_environments: [:prod],
  in_app_module_whitelist: [Asciinema]

if System.get_env("S3_BUCKET") do
  config :asciinema, :file_store, Asciinema.FileStore.Cached

  config :asciinema, Asciinema.FileStore.Cached,
    remote_store: Asciinema.FileStore.S3,
    cache_store: Asciinema.FileStore.Local

  config :asciinema, Asciinema.FileStore.S3,
    region: System.get_env("S3_REGION"),
    bucket: System.get_env("S3_BUCKET"),
    path: "uploads/"

  config :ex_aws,
    access_key_id: [{:system, "AWS_ACCESS_KEY_ID"}, :instance_role],
    secret_access_key: [{:system, "AWS_SECRET_ACCESS_KEY"}, :instance_role]

  config :asciinema, Asciinema.FileStore.Local, path: "tmp/cache/uploads/"
else
  config :asciinema, :file_store, Asciinema.FileStore.Local
  config :asciinema, Asciinema.FileStore.Local, path: "uploads/"
end

config :asciinema, :png_generator, Asciinema.PngGenerator.Rsvg
config :asciinema, Asciinema.PngGenerator.Rsvg,
  pool_size: String.to_integer(System.get_env("RSVG_POOL_SIZE") || "2"),
  font_family: System.get_env("RSVG_FONT_FAMILY") || "monospace"

config :asciinema, :snapshot_updater, Asciinema.Asciicasts.SnapshotUpdater.Exq

config :asciinema, :home_asciicast_id, System.get_env("HOME_ASCIICAST_ID")

config :exq,
  name: Exq,
  start_on_application: false,
  url: System.get_env("REDIS_URL") || "redis://localhost:6379",
  namespace: "exq",
  concurrency: 10,
  queues: ["default", "emails"],
  scheduler_enable: true,
  max_retries: 25,
  shutdown_timeout: 5000,
  middleware: [Exq.Middleware.Stats, Exq.Middleware.Job, Exq.Middleware.Manager,
               Exq.Middleware.Logger, Asciinema.Exq.Middleware.Sentry]

config :exq_ui,
  web_port: 4040,
  web_namespace: "",
  server: true

config :scrivener_html,
  view_style: :bootstrap_v4

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
