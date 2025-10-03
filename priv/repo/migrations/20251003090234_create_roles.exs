defmodule AsBackendTheme2.Repo.Migrations.CreateRoles do
  use Ecto.Migration

  # We use explicit up/down because we're executing raw SQL for seeding.
  def up do
    create table(:roles) do
      add :name, :string, null: false
      timestamps()
    end

    # Each role name must be unique (prevents duplicates)
    create unique_index(:roles, [:name])

    # Seed fixed roles. ON CONFLICT avoids errors if this migration is re-run.
    execute("""
    INSERT INTO roles (name, inserted_at, updated_at)
    VALUES
      ('employee', NOW(), NOW()),
      ('manager',  NOW(), NOW()),
      ('admin',    NOW(), NOW())
    ON CONFLICT (name) DO NOTHING;
    """)
  end

  def down do
    drop table(:roles)
  end
end
