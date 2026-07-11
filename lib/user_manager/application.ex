defmodule UserManager.Application do
  # See https://elixir.hexdocs.pm/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      UserManagerWeb.Telemetry,
      UserManager.Repo,
      {DNSCluster, query: Application.get_env(:user_manager, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: UserManager.PubSub},
      # Start a worker by calling: UserManager.Worker.start_link(arg)
      # {UserManager.Worker, arg},
      # Start to serve requests, typically the last entry
      UserManagerWeb.Endpoint
    ]

    # See https://elixir.hexdocs.pm/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: UserManager.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    UserManagerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
