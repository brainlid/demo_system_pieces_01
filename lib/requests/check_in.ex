defmodule SystemPieces.Requests.CheckIn do
  @moduledoc """
  Schema validation for request to check-in.
  """

  @type t :: %__MODULE__{}

  use Ecto.Schema
  import Ecto.Changeset
  require Logger

  embedded_schema do
    field :insurance_policy, :string, null: false
    # address
    field :address_line_1, :string
    field :address_line_2, :string
    field :city, :string
    field :state, :string
    field :postal_code, :string
    field :country, :string, default: "USA"
    # personal contact
    field :contact_name, :string
    field :contact_email, :string
    field :contact_phone, :string
  end

  @valid_countries ~w(USA CAN)

  @required_fields ~w(insurance_policy contact_name)a
  @optional_fields ~w(address_line_1 address_line_2
                      city state postal_code country
                      contact_email contact_phone)a
  @all_fields @required_fields ++ @optional_fields

  def build(params) do
    %__MODULE__{}
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:country, @valid_countries)
  end

  def create(params) do
    params
    |> build
    |> handle_create
  end

  defp handle_create(changeset) do
    if changeset.valid? do
      {:ok, apply_changes(changeset)}
    else
      {:error, changeset}
    end
  end
end
