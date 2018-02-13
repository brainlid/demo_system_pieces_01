defmodule SystemPieces.HealthMonitor.HealthMonitorPlain do
  @moduledoc """
  GenServer that runs a periodic connection status check for external system.
  Keeps the status of the last check in state so it can be queried at any time.
  """
  use GenServer
  require Logger
  alias SystemPieces.Utils
  alias SystemPieces.HealthMonitor.State

  @name __MODULE__

  ###
  ### CLIENT
  ###

  @spec start_link(initial :: map, opts :: Keyword.t) :: :ok
  def start_link(initial, opts \\ []) do
    name = get_name(opts)
    GenServer.start_link(name, initial, [name: name])
  end

  @doc """
  Return the status of the last check.
  """
  @spec status(opts :: Keyword.t) :: State.status_result
  def status(opts \\ []) do
    GenServer.call(get_name(opts), :status)
  end

  ###
  ### SERVER (callbacks)
  ###

  def init(initial) do
    Utils.color(:magenta)
    Utils.say("Starting #{inspect __MODULE__}", delay: :short)
    Process.send_after(self(), :interval_check, 1)
    state = %State{check_interval: Map.get(initial, :check_interval, -1)}
    {:ok, state}
  end

  def handle_info(:interval_check, state) do
    schedule_check(state)
    new_state = perform_check(state)
    {:noreply, new_state}
  end
  def handle_info(request, state) do
    # Call the default implementation from GenServer
    super(request, state)
  end

  def handle_call(:status, _from, %State{} = state) do
    {:reply, State.as_status(state), state}
  end
  def handle_call(request, from, state) do
    # Call the default implementation from GenServer
    super(request, from, state)
  end

  ###
  ### PRIVATE
  ###

  @doc """
  Performs the external service API connectivity test. Logs errors.

  This is not private to aid in testing only.
  """
  @spec perform_check(State.t) :: State.t
  def perform_check(%State{check_interval: interval} = state) do
    Utils.say("Checking...", delay: :short)
    # Simulate making network request. Sleeps for 1.4 seconds
    Process.sleep(1_400)

    if interval > 0 do
      # pretending it is always successful
      new_status = :live

      State.set_status(state, new_status)
    else
      state
    end
  end

  defp schedule_check(%State{check_interval: interval}) do
    if interval > 0 do
      Process.send_after(self(), :interval_check, interval)
    else
      Logger.info("#{inspect __MODULE__} interval checks are disabled")
      :ok
    end
  end

  defp get_name(opts) do
    Keyword.get(opts, :name, @name)
  end
end
