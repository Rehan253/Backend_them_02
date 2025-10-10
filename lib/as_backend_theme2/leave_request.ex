defmodule AsBackendTheme2.Leaves.LeaveRequest do
  use Ecto.Schema
  import Ecto.Changeset

  @valid_leave_types ["Vacation", "Sick Leave", "Personal Day", "Emergency", "Other"]
  @valid_statuses ["Pending", "Approved", "Rejected"]

  schema "leave_requests" do
    field :leave_type, :string
    field :start_date, :date
    field :end_date, :date
    field :reason, :string
    field :status, :string, default: "Pending"

    belongs_to :user, AsBackendTheme2.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc """
  Validates a leave request.
  The controller will inject the correct user_id from JWT.
  """
  def changeset(leave_request, attrs) do
    leave_request
    |> cast(attrs, [:leave_type, :start_date, :end_date, :reason, :status, :user_id])
    |> validate_required([:leave_type, :start_date, :end_date, :reason, :user_id])
    |> validate_inclusion(:leave_type, @valid_leave_types)
    |> validate_inclusion(:status, @valid_statuses)
    |> validate_date_order()
  end

  defp validate_date_order(changeset) do
    start_date = get_field(changeset, :start_date)
    end_date = get_field(changeset, :end_date)

    if start_date && end_date && Date.compare(end_date, start_date) == :lt do
      add_error(changeset, :end_date, "must be after start date")
    else
      changeset
    end
  end
end
