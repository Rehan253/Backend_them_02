defmodule AsBackendTheme2.Repo.Migrations.AddAuthFieldsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :password_hash, :string
      add :skills, :string
      add :role_id, references(:roles, on_delete: :restrict)
    end

    create index(:users, [:role_id])
  end
end
