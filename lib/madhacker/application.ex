defmodule Madhacker.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the endpoint when the application starts
      MadhackerWeb.Endpoint,
      # Starts a worker by calling: Madhacker.Worker.start_link(arg)
      # {Madhacker.Worker, arg},
      { Madhacker.MatchMaker, [] },
      { DynamicSupervisor, strategy: :one_for_one, name: Madhacker.GameSupervisor }
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Madhacker.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    MadhackerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
