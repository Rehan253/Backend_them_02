defmodule AsBackendTheme2.TimeTracking.Clock do
  @moduledoc """
  Clock schema for tracking user clock in/out events.

  This schema represents individual clock in/out entries:
  - time: When the clock event occurred
  - status: true = clocked in, false = clocked out
  - user_id: Reference to the user who performed the action

  Clock Convention:
  - status: true = User is clocked in (working)
  - status: false = User is clocked out (not working)
  """

  use Ecto.Schema
  import Ecto.Changeset

  # Only serialize these fields to JSON
  @derive {Jason.Encoder, only: [:id, :time, :status, :user_id, :inserted_at, :updated_at]}

  schema "clocks" do
    field :time, :naive_datetime
    field :status, :boolean

    belongs_to :user, AsBackendTheme2.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc """
  Creates a changeset for clock entries.

  ## Parameters
  - `clock`: Clock struct or changeset
  - `attrs`: Map containing time, status, and user_id

  ## Returns
  Changeset with validations applied
  """
  def changeset(clock, attrs) do
    clock
    |> cast(attrs, [:time, :status, :user_id])
    |> validate_required([:time, :status, :user_id])
  end
end
