defmodule AsBackendTheme2.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :first_name, :last_name, :email, :skills, :address, :role_id, :role]}

  schema "users" do
    field :first_name, :string
    field :last_name, :string
    field :email, :string

    # used only in memory
    field :password, :string, virtual: true
    # stored in DB
    field :password_hash, :string
    # optional
    field :skills, :string
    # optional
    field :address, :string

    belongs_to :role, AsBackendTheme2.Accounts.Role
    has_many :working_times, AsBackendTheme2.TimeTracking.WorkingTime
    has_many :clocks, AsBackendTheme2.TimeTracking.Clock
    has_many :team_memberships, AsBackendTheme2.Accounts.TeamMembership
    many_to_many :teams, AsBackendTheme2.Team, join_through: AsBackendTheme2.Accounts.TeamMembership


    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:first_name, :last_name, :email, :skills, :address, :role_id])
    |> validate_required([:first_name, :last_name, :email])
    |> unique_constraint(:email)
  end

  def registration_changeset(user, attrs) do
    user
    |> cast(attrs, [:first_name, :last_name, :email, :password, :skills, :address, :role_id])
    |> validate_required([:first_name, :last_name, :email, :password])
    |> validate_format(:email, ~r/^[^@\s]+@[^@\s]+\.[^@\s]+$/, message: "must be a valid email")
    |> unique_constraint(:email, message: "email already exists")
    |> validate_length(:password, min: 6)
    |> hash_password()
  end

  defp hash_password(changeset) do
    if pw = get_change(changeset, :password) do
      change(changeset, password_hash: Argon2.hash_pwd_salt(pw))
    else
      changeset
    end
  end
end
