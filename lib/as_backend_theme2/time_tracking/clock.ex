defmodule AsBackendTheme2.TimeTracking.Clock do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :time, :status, :user_id, :inserted_at, :updated_at]}

  schema "clocks" do
    field :time, :naive_datetime
    field :status, :boolean

    belongs_to :user, AsBackendTheme2.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(clock, attrs) do
    clock
    |> cast(attrs, [:time, :status, :user_id])
    |> validate_required([:time, :status, :user_id])
  end
end
