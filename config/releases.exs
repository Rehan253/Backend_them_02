import Config

config :as_backend_theme2, AsBackendTheme2.Repo,
  url: System.get_env("DATABASE_URL"),
  pool_size: 10,
  ssl: false

config :as_backend_theme2, AsBackendTheme2Web.Endpoint,
  http: [port: String.to_integer(System.get_env("PORT") || "4000")],
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  server: true
