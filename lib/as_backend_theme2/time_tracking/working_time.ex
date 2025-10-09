defmodule AsBackendTheme2.TimeTracking.WorkingTime do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder,
           only: [:id, :start, :end, :user_id, :shift_type, :overtime, :inserted_at, :updated_at]}
  @shift_types ~w(day night)

  schema "working_times" do
    field :start, :naive_datetime
    field :end, :naive_datetime

    # NEW FIELDS added by the migration
    # "day" | "night"
    field :shift_type, :string, default: "day"
    field :overtime, :boolean, default: false

    belongs_to :user, AsBackendTheme2.Accounts.User
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(working_time, attrs) do
    working_time
    |> cast(attrs, [:start, :end, :user_id, :shift_type, :overtime])
    |> validate_required([:start, :end, :user_id])
    # set "day"/"night" if not provided
    |> compute_shift_type()
    # keep false unless explicitly set
    |> put_default_overtime()
    # friendly validation
    |> validate_inclusion(:shift_type, @shift_types)
    # DB check
    |> check_constraint(:shift_type, name: :shift_type_must_be_day_or_night)
  end

  # ---- helpers --------------------------------------------------------------

  # If caller didn't pass :shift_type, infer it from the :start hour:
  # "night" for hours 22:00–05:59, otherwise "day"
  # If the client did NOT pass :shift_type, infer it from :start hour.
  defp compute_shift_type(changeset) do
    # Only auto-set if client didn't explicitly provide :shift_type
    case get_change(changeset, :shift_type) do
      nil ->
        # Use the submitted start time if present, otherwise existing value
        start_val = get_change(changeset, :start) || get_field(changeset, :start)

        case start_val do
          %NaiveDateTime{hour: h} when h >= 22 or h < 6 ->
            put_change(changeset, :shift_type, "night")

          %NaiveDateTime{} ->
            put_change(changeset, :shift_type, "day")

          _ ->
            changeset
        end

      _explicit ->
        # Caller provided shift_type — respect it.
        changeset
    end
  end

  # Ensure :overtime has a boolean value (defaults to false).
  # We'll compute actual weekly overtime in the payroll step.
  defp put_default_overtime(changeset) do
    case get_field(changeset, :overtime) do
      nil -> put_change(changeset, :overtime, false)
      _ -> changeset
    end
  end
end
