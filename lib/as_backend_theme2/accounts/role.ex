defmodule AsBackendTheme2.Accounts.Role do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :name]}

  schema "roles" do
    field :name, :string
    has_many :users, AsBackendTheme2.Accounts.User
    timestamps()
  end

  @doc false
  def changeset(role, attrs) do
    role
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
