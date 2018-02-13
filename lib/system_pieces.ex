defmodule SystemPieces do
  @moduledoc """
  Documentation for SystemPieces demo project.
  """
  alias SystemPieces.HealthMonitor.HealthMonitorEts
  alias SystemPieces.HealthMonitor.HealthMonitorPlain


  def check_status_ets do
    HealthMonitorEts.status()
  end

  def check_status_plain do
    HealthMonitorPlain.status()
  end

  @doc """
  Benchmark results:

      Name                         ips        average  deviation         median         99th %
      check_status_ets          5.61 M       0.178 μs   ±127.12%       0.170 μs        0.31 μs
      check_status_plain        0.53 M        1.88 μs ±48112.28%           1 μs           3 μs

      Comparison:
      check_status_ets          5.61 M
      check_status_plain        0.53 M - 10.53x slower

  The point is that the "plain" variation has a much larger standard deviation
  because while it is doing the work of checking the status, it cannot respond
  to requests.
  """
  def benchmark_check_status do
    Benchee.run(%{
      "check_status_ets"    => fn -> HealthMonitorEts.status() end,
      "check_status_plain"  => fn -> HealthMonitorPlain.status() end
    }, time: 10)
  end
end
