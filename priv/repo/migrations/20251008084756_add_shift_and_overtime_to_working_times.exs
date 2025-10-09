defmodule AsBackendTheme2.Repo.Migrations.AddShiftAndOvertimeToWorkingTimes do
  use Ecto.Migration

  def change do
    alter table(:working_times) do
      add :shift_type, :string, null: false, default: "day"   # "day" | "night"
      add :overtime, :boolean, null: false, default: false
    end

    # Optional safety: only allow "day" or "night"
    create constraint(
             :working_times,
             :shift_type_must_be_day_or_night,
             check: "shift_type in ('day','night')"
           )
  end
end
