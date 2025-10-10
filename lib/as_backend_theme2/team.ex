defmodule AsBackendTheme2.Team do
  use Ecto.Schema
  import Ecto.Changeset

  schema "teams" do
    field :name, :string
    belongs_to :manager, AsBackendTheme2.Accounts.User
    has_many :team_memberships, AsBackendTheme2.Accounts.TeamMembership
    many_to_many :users, AsBackendTheme2.Accounts.User, join_through: AsBackendTheme2.Accounts.TeamMembership


    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(team, attrs) do
    team
    |> cast(attrs, [:name, :manager_id])
    |> validate_required([:name])
  end
end
