defmodule AsBackendTheme2.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :first_name, :string
    field :last_name, :string

    has_many :working_times, AsBackendTheme2.TimeTracking.WorkingTime
    has_many :clocks, AsBackendTheme2.TimeTracking.Clock

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :first_name, :last_name])
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^@\s]+@[^@\s]+\.[^@\s]+$/, message: "must be a valid email")
    |> unique_constraint(:email, message: "email already exists")
  end
end
