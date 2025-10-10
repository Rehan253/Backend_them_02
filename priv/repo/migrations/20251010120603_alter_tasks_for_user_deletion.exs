defmodule AsBackendTheme2.Repo.Migrations.AlterTasksForUserDeletion do
  use Ecto.Migration

  def change do
    # Drop existing foreign key constraints
    drop constraint(:tasks, :tasks_assigned_to_id_fkey)
    drop constraint(:tasks, :tasks_assigned_by_id_fkey)
    
    # Alter columns to allow null values
    alter table(:tasks) do
      modify :assigned_to_id, references(:users, on_delete: :nilify_all), null: true
      modify :assigned_by_id, references(:users, on_delete: :nilify_all), null: true
    end
  end
end
