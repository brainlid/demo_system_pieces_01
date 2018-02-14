defmodule SystemPieces do
  @moduledoc """
  Documentation for SystemPieces demo project.
  """
  alias SystemPieces.HealthMonitor.HealthMonitorEts
  alias SystemPieces.HealthMonitor.HealthMonitorPlain
  alias SystemPieces.Requests.CheckIn
  alias SystemPieces.Utils.Errors
  require Logger


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

  @doc """
  Check-in to the system. Must provide required information.
  Errors are returned converted to a string.
  """
  @spec check_in(params :: map)
    :: {:ok, id :: integer}|{:error, reason :: String.t}
  def check_in(params) do
    case CheckIn.create(params) do
      {:ok, request} ->
        queue_request(request)
      {:error, _} = error ->
        log_and_return_request_error("CheckIn", error)
    end
  end

  @doc """
  Simple example to make it easy to create a valid entry.
  """
  def check_in_valid do
    check_in(%{contact_name: "Tim", insurance_policy: "A987654"})
  end

  def queue_request(request) do
    # NOTE: add the request to a queue, worker processes it.
    #       return an ID for the job
    Logger.info("Process request #{inspect request}")
    {:ok, 1}
  end

  @spec log_and_return_request_error(request_type :: String.t, error :: tuple) :: {:error, String.t}
  defp log_and_return_request_error(request_type, error) do
    {:error, reason} = error = Errors.convert_error_changeset(error)
    Logger.error("Error while creating #{request_type} request: #{inspect reason}")
    error
  end

end
