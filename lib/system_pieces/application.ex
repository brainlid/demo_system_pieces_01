defmodule SystemPieces.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
  alias SystemPieces.HealthMonitor.HealthMonitorEts
  alias SystemPieces.HealthMonitor.HealthMonitorPlain

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: SystemPieces.Worker.start_link(arg)
      {HealthMonitorEts, %{check_interval: 10_000}},
      {HealthMonitorPlain, %{check_interval: 10_000}},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SystemPieces.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
