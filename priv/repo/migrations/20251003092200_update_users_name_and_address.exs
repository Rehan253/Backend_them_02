defmodule AsBackendTheme2.Repo.Migrations.UpdateUsersNameAndAddress do
  use Ecto.Migration

  def change do
    alter table(:users) do
 #     add :first_name, :string
  #    add :last_name, :string
      add :address, :string
    end
  end
end
