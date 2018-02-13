defmodule SystemPieces.HealthMonitor.State do
  @moduledoc """
  State struct for the `SystemPieces.HealthMonitor`. Helps track state
  and manage state changes.
  """

  @typedoc """
  When it was last checked is stored as a Unix timestamp
  """
  @type last_check :: nil|integer

  @type status :: nil | :live | {:error, message :: String.t}

  defstruct [
    check_interval: -1,
    status: :live,
    last_check: nil,
    cache_table: nil
  ]
  @type t :: %__MODULE__{
    check_interval: integer,
    status: status,
    last_check: last_check,
    cache_table: nil|atom
  }

  @type status_result :: {:live, last_check}|{:error, reason :: String.t, last_check}

  @spec set_status(t, HealthMonitor.status) :: t
  def set_status(state, status) do
    now_unix = DateTime.to_unix(DateTime.utc_now)
    %__MODULE__{state | last_check: now_unix, status: status}
  end

  @spec as_status(t) :: status_result
  def as_status(%__MODULE__{status: :live, last_check: at}), do: {:live, at}
  def as_status(%__MODULE__{status: {:error, reason}, last_check: at}), do: {:error, reason, at}
end
