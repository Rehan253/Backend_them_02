defmodule AsBackendTheme2.Accounts.TeamMembership do
  use Ecto.Schema
  import Ecto.Changeset

  schema "team_memberships" do
    belongs_to :user, AsBackendTheme2.Accounts.User
    belongs_to :team, AsBackendTheme2.Team

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(membership, attrs) do
    membership
    |> cast(attrs, [:user_id, :team_id])
    |> validate_required([:user_id, :team_id])
    |> unique_constraint([:user_id, :team_id])
  end
end
