defmodule AsBackendTheme2.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add :title, :string, null: false
      add :description, :text, null: false
      add :status, :string, default: "pending", null: false
      add :priority, :string, default: "medium", null: false
      add :due_date, :date, null: false
      add :assigned_to_id, references(:users, on_delete: :nilify_all), null: true
      add :assigned_by_id, references(:users, on_delete: :nilify_all), null: true
      add :team_id, references(:teams, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:tasks, [:assigned_to_id])
    create index(:tasks, [:assigned_by_id])
    create index(:tasks, [:team_id])
    create index(:tasks, [:status])
    create index(:tasks, [:priority])
    create index(:tasks, [:due_date])

    # Add constraints for status and priority values
    create constraint(:tasks, :status_must_be_valid, 
      check: "status IN ('pending', 'in_progress', 'completed', 'cancelled')")
    
    create constraint(:tasks, :priority_must_be_valid, 
      check: "priority IN ('low', 'medium', 'high')")
  end
end
