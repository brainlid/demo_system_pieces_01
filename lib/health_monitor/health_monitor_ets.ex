defmodule SystemPieces.HealthMonitor.HealthMonitorEts do
  @moduledoc """
  GenServer that runs a periodic connection status check for external system.
  Keeps the status of the last check in state so it can be queried at any time.
  """
  use GenServer
  require Logger
  alias SystemPieces.Utils
  alias SystemPieces.HealthMonitor.State

  @name __MODULE__

  @ets_table :health_monitor_status_cache_name

  ###
  ### CLIENT
  ###

  @spec start_link(initial :: map, opts :: Keyword.t) :: :ok
  def start_link(initial, opts \\ []) do
    name = get_name(opts)
    GenServer.start_link(@name, initial, [name: name])
  end

  @doc """
  Return the status of the last check.
  """
  @spec status(opts :: Keyword.t) :: State.status_result
  def status(opts \\ []) do
    read_cached_status(opts)
  end

  ###
  ### SERVER (callbacks)
  ###

  def init(initial) do
    Utils.color(:blue)
    Utils.say("Starting #{inspect __MODULE__}", delay: :short)
    Process.send_after(self(), :interval_check, 1)
    state =
      %State{
        check_interval: Map.get(initial, :check_interval, -1),
        cache_table: Map.get(initial, :cache_table, @ets_table)
      }
    setup_cache_table(state)
    write_cached_status(state)
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

      state
      |> State.set_status(new_status)
      |> write_cached_status()
    else
      state
    end
  end

  @spec setup_cache_table(State.t) :: :ok
  defp setup_cache_table(%State{cache_table: cache_table}) do
    :ets.new(cache_table, [:set, :named_table, :protected])
    :ok
  end

  @spec write_cached_status(State.t) :: State.t
  defp write_cached_status(%State{cache_table: cache_table} = state) do
    # writes the status to the ETS cache table.
    # Since the tables is setup as a :set, an insert replaces an existing value
    :ets.insert(cache_table, {:status, State.as_status(state)})
    state
  end

  @spec read_cached_status(opts :: Keyword.t) :: State.status_result
  defp read_cached_status(opts) do
    cache_table = Keyword.get(opts, :cache_table, @ets_table)
    case :ets.lookup(cache_table, :status) do
      [] -> nil
      list when is_list(list) -> Keyword.get(list, :status)
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
