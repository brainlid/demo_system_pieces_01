defmodule SystemPieces.Visits do
  @moduledoc """
  Provides access functions for reading and writing a Visit.

  In this example, we might be storing visit records in a `visits` table.
  This module would be for reading, fetching, searching, inserting those
  records.
  """

  @doc """
  Example function for fetching a single record.

  ## Examples

      Visits.get(1)
      Visits.get("1")
      Visits.get(id: 1)
      Visits.get([id: 1])
      
  """
  def get(id) when is_integer(id) or is_binary(id) do
    get([id: id])
  end
  def get(_clauses) do
    # Repo.one(from Visits, where: ^clauses)
    nil
  end

  @doc """
  Lookup a Visit returning it an tuple.

  ## Examples

      Visits.find(id: 1)
      Visits.find(user_id: 12, date_on: ~N[2018-02-01])

  """
  def find(clauses) do
    case get(clauses) do
      nil -> {:error, "Visit not found"}
      visit -> {:ok, visit}
    end
  end

  @doc """
  Return all the visits that match the search criteria.
  """
  def all_visits(_clauses) do
    # Repo.all(
    #   from v in Visit,
    #   where: ^clauses,
    #   order_by: [asc: :inserted_at]
    # )
    []
  end

end
