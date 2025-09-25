defmodule AsBackendTheme2.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      AsBackendTheme2Web.Telemetry,
      AsBackendTheme2.Repo,
      {DNSCluster, query: Application.get_env(:as_backend_theme2, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: AsBackendTheme2.PubSub},
      # Start a worker by calling: AsBackendTheme2.Worker.start_link(arg)
      # {AsBackendTheme2.Worker, arg},
      # Start to serve requests, typically the last entry
      AsBackendTheme2Web.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AsBackendTheme2.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AsBackendTheme2Web.Endpoint.config_change(changed, removed)
    :ok
  end
end
