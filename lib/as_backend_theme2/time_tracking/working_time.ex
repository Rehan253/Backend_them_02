defmodule AsBackendTheme2.TimeTracking.WorkingTime do
  use Ecto.Schema
  import Ecto.Changeset
  @derive {Jason.Encoder, only: [:id, :start, :end, :user_id, :inserted_at, :updated_at]}

  schema "working_times" do
    field :start, :naive_datetime
    field :end, :naive_datetime

    belongs_to :user, AsBackendTheme2.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(working_time, attrs) do
    working_time
    |> cast(attrs, [:start, :end, :user_id])
    |> validate_required([:start, :end, :user_id])
  end
end
