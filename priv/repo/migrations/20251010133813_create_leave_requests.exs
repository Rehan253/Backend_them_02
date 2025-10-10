def change do
  create table(:leave_requests) do
    add :leave_type, :string, null: false
    add :start_date, :date, null: false
    add :end_date, :date, null: false
    add :reason, :text, null: false
    add :status, :string, null: false, default: "Pending"
    add :user_id, references(:users, on_delete: :delete_all), null: false

    timestamps(type: :utc_datetime)
  end

  create index(:leave_requests, [:user_id])
  create constraint(:leave_requests, :end_date_after_start_date,
    check: "end_date >= start_date"
  )
end
