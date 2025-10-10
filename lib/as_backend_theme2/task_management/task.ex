defmodule AsBackendTheme2.TaskManagement.Task do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tasks" do
    field :title, :string
    field :description, :string
    field :status, :string, default: "pending"
    field :priority, :string, default: "medium"
    field :due_date, :date

    belongs_to :assigned_to, AsBackendTheme2.Accounts.User, foreign_key: :assigned_to_id
    belongs_to :assigned_by, AsBackendTheme2.Accounts.User, foreign_key: :assigned_by_id
    belongs_to :team, AsBackendTheme2.Team

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:title, :description, :status, :priority, :assigned_to_id, :assigned_by_id, :team_id, :due_date])
    |> validate_required([:title, :description, :team_id, :due_date])
    |> validate_inclusion(:status, ["pending", "in_progress", "completed", "cancelled"])
    |> validate_inclusion(:priority, ["low", "medium", "high"])
    |> foreign_key_constraint(:assigned_to_id)
    |> foreign_key_constraint(:assigned_by_id)
    |> foreign_key_constraint(:team_id)
  end
end
