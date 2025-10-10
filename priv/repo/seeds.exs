alias AsBackendTheme2.Repo
alias AsBackendTheme2.Accounts.User
alias AsBackendTheme2.TimeTracking.WorkingTime
alias AsBackendTheme2.TimeTracking.Clock
alias AsBackendTheme2.Team
alias AsBackendTheme2.Accounts.TeamMembership
alias AsBackendTheme2.TaskManagement
alias AsBackendTheme2.TaskManagement.Task

users = [
  %{
    email: "admin@gotham.com",
    first_name: "Admin",
    last_name: "Admin",
    password: "admin123",
    role_id: 3
  },
  %{
    email: "manager@gotham.com",
    first_name: "Alfred",
    last_name: "Pennyworth",
    password: "manager123",
    role_id: 2
  },
  %{
    email: "manager2@gotham.com",
    first_name: "Bruce",
    last_name: "Wayne",
    password: "manager123",
    role_id: 2
  },
  %{
    email: "manager3@gotham.com",
    first_name: "Selina",
    last_name: "Kyle",
    password: "manager123",
    role_id: 2
  },
  %{
    email: "john.doe@example.com",
    first_name: "John",
    last_name: "Doe",
    password: "password123",
    role_id: 1
  },
  %{
    email: "jane.smith@example.com",
    first_name: "Jane",
    last_name: "Smith",
    password: "password123",
    role_id: 1
  },
  %{
    email: "bob.wilson@example.com",
    first_name: "Bob",
    last_name: "Wilson",
    password: "password123",
    role_id: 1
  },
  %{
    email: "alice.brown@example.com",
    first_name: "Alice",
    last_name: "Brown",
    password: "password123",
    role_id: 1
  },
  %{
    email: "charlie.davis@example.com",
    first_name: "Charlie",
    last_name: "Davis",
    password: "password123",
    role_id: 1
  },
  %{
    email: "sarah.johnson@example.com",
    first_name: "Sarah",
    last_name: "Johnson",
    password: "password123",
    role_id: 1
  },
  %{
    email: "mike.garcia@example.com",
    first_name: "Mike",
    last_name: "Garcia",
    password: "password123",
    role_id: 1
  },
  %{
    email: "lisa.martinez@example.com",
    first_name: "Lisa",
    last_name: "Martinez",
    password: "password123",
    role_id: 1
  },
  %{
    email: "david.lee@example.com",
    first_name: "David",
    last_name: "Lee",
    password: "password123",
    role_id: 1
  },
  %{
    email: "emma.taylor@example.com",
    first_name: "Emma",
    last_name: "Taylor",
    password: "password123",
    role_id: 1
  }
]

user_ids =
  for user_data <- users do
    case Repo.get_by(User, email: user_data.email) do
      nil ->
        case AsBackendTheme2.Accounts.create_user(user_data) do
          {:ok, user} -> user.id
          {:error, _changeset} -> nil
        end
      existing_user -> existing_user.id
    end
  end

user_ids = Enum.filter(user_ids, &(&1 != nil))

{:ok, counter} = Agent.start_link(fn -> %{working_time_count: 0, clock_count: 0} end)

work_patterns = [
  %{start_hour_range: {7, 10}, work_duration_range: {6, 12}, weekend_work_chance: 0.3},
  %{start_hour_range: {8, 9}, work_duration_range: {8, 10}, weekend_work_chance: 0.1},
  %{start_hour_range: {8, 9}, work_duration_range: {7, 9}, weekend_work_chance: 0.05},
  %{start_hour_range: {8, 9}, work_duration_range: {7, 9}, weekend_work_chance: 0.05},
  %{start_hour_range: {8, 9}, work_duration_range: {7, 9}, weekend_work_chance: 0.05},
  %{start_hour_range: {8, 9}, work_duration_range: {7, 9}, weekend_work_chance: 0.05},
  %{start_hour_range: {8, 9}, work_duration_range: {7, 9}, weekend_work_chance: 0.05},
  %{start_hour_range: {8, 9}, work_duration_range: {7, 9}, weekend_work_chance: 0.05},
  %{start_hour_range: {8, 9}, work_duration_range: {7, 9}, weekend_work_chance: 0.05},
  %{start_hour_range: {8, 9}, work_duration_range: {7, 9}, weekend_work_chance: 0.05},
  %{start_hour_range: {8, 9}, work_duration_range: {7, 9}, weekend_work_chance: 0.05},
  %{start_hour_range: {8, 9}, work_duration_range: {7, 9}, weekend_work_chance: 0.05}
]

for {user_id, user_index} <- Enum.with_index(user_ids) do
  user = Repo.get!(User, user_id)
  pattern = Enum.at(work_patterns, user_index) || Enum.at(work_patterns, 2)

  for day <- 0..89 do
    date = Date.add(Date.utc_today(), -day)

    should_work = Date.day_of_week(date) in [1, 2, 3, 4, 5] or
                  (:rand.uniform(100) <= (pattern.weekend_work_chance * 100))

    if should_work do
      {min_start, max_start} = pattern.start_hour_range
      start_hour = :rand.uniform(max_start - min_start + 1) + min_start - 1
      start_minute = :rand.uniform(60) - 1

      {min_duration, max_duration} = pattern.work_duration_range
      work_duration_hours = :rand.uniform(max_duration - min_duration + 1) + min_duration - 1

      end_hour = start_hour + work_duration_hours
      end_minute = start_minute + :rand.uniform(60) - 1

      {end_hour, end_minute} =
        if end_hour >= 23 do
          {22, 59}
        else
          {end_hour, end_minute}
        end

      {end_hour, end_minute} =
        if end_minute >= 60 do
          {end_hour + 1, end_minute - 60}
        else
          {end_hour, end_minute}
        end

      {end_hour, end_minute} =
        if end_hour >= 24 do
          {23, 59}
        else
          {end_hour, end_minute}
        end

      start_time = NaiveDateTime.new!(date, Time.new!(start_hour, start_minute, 0))
      end_time = NaiveDateTime.new!(date, Time.new!(end_hour, end_minute, 0))

      working_time_data = %{
        start: start_time,
        end: end_time,
        user_id: user_id
      }

      case Repo.get_by(WorkingTime, user_id: user_id, start: start_time) do
        nil ->
          case AsBackendTheme2.TimeTracking.create_working_time(working_time_data) do
            {:ok, _working_time} ->
              Agent.update(counter, fn state ->
                %{state | working_time_count: state.working_time_count + 1}
              end)
            {:error, _changeset} -> :ok
          end
        _existing -> :ok
      end

      clock_in_time = NaiveDateTime.new!(date, Time.new!(start_hour, start_minute, 0))
      clock_out_time = NaiveDateTime.new!(date, Time.new!(end_hour, end_minute, 0))

      clock_in_data = %{
        time: clock_in_time,
        status: true,
        user_id: user_id
      }

      case Repo.get_by(Clock, user_id: user_id, time: clock_in_time) do
        nil ->
          case AsBackendTheme2.TimeTracking.create_clock(clock_in_data) do
            {:ok, _clock} ->
              Agent.update(counter, fn state ->
                %{state | clock_count: state.clock_count + 1}
              end)
            {:error, _changeset} -> :ok
          end
        _existing -> :ok
      end

      clock_out_data = %{
        time: clock_out_time,
        status: false,
        user_id: user_id
      }

      case Repo.get_by(Clock, user_id: user_id, time: clock_out_time) do
        nil ->
          case AsBackendTheme2.TimeTracking.create_clock(clock_out_data) do
            {:ok, _clock} ->
              Agent.update(counter, fn state ->
                %{state | clock_count: state.clock_count + 1}
              end)
            {:error, _changeset} -> :ok
          end
        _existing -> :ok
      end

      if work_duration_hours >= 6 and :rand.uniform(3) == 1 do
        break_start_hour = start_hour + 4
        break_start_minute = start_minute + :rand.uniform(30)
        break_end_hour = break_start_hour
        break_end_minute = break_start_minute + 30 + :rand.uniform(30)

        {break_start_hour, break_start_minute} =
          if break_start_minute >= 60 do
            {break_start_hour + 1, break_start_minute - 60}
          else
            {break_start_hour, break_start_minute}
          end

        {break_end_hour, break_end_minute} =
          if break_end_minute >= 60 do
            {break_end_hour + 1, break_end_minute - 60}
          else
            {break_end_hour, break_end_minute}
          end

        break_start_hour = min(break_start_hour, 23)
        break_end_hour = min(break_end_hour, 23)
        break_start_minute = min(break_start_minute, 59)
        break_end_minute = min(break_end_minute, 59)

        if break_end_hour < end_hour or (break_end_hour == end_hour and break_end_minute < end_minute) do
          break_start_time = NaiveDateTime.new!(date, Time.new!(break_start_hour, break_start_minute, 0))
          break_end_time = NaiveDateTime.new!(date, Time.new!(break_end_hour, break_end_minute, 0))

          break_clock_out_data = %{
            time: break_start_time,
            status: false,
            user_id: user_id
          }

          case Repo.get_by(Clock, user_id: user_id, time: break_start_time) do
            nil ->
              case AsBackendTheme2.TimeTracking.create_clock(break_clock_out_data) do
                {:ok, _clock} ->
                  Agent.update(counter, fn state ->
                    %{state | clock_count: state.clock_count + 1}
                  end)
                _ -> :ok
              end
            _ -> :ok
          end

          break_clock_in_data = %{
            time: break_end_time,
            status: true,
            user_id: user_id
          }

          case Repo.get_by(Clock, user_id: user_id, time: break_end_time) do
            nil ->
              case AsBackendTheme2.TimeTracking.create_clock(break_clock_in_data) do
                {:ok, _clock} ->
                  Agent.update(counter, fn state ->
                    %{state | clock_count: state.clock_count + 1}
                  end)
                _ -> :ok
              end
            _ -> :ok
          end
        end
      end
    end
  end
end

teams_data = [
  %{name: "Development Team", manager_id: 2},  # Alfred Pennyworth
  %{name: "Design Team", manager_id: 3},       # Bruce Wayne
  %{name: "Marketing Team", manager_id: 4},   # Selina Kyle
  %{name: "Operations Team", manager_id: 2}   # Alfred Pennyworth (manages multiple teams)
]

team_ids = for team_data <- teams_data do
  case Repo.get_by(Team, name: team_data.name) do
    nil ->
      case Repo.insert(Team.changeset(%Team{}, team_data)) do
        {:ok, team} -> team.id
        {:error, _changeset} -> nil
      end
    existing_team -> existing_team.id
  end
end

team_ids = Enum.filter(team_ids, &(&1 != nil))

all_users = Repo.all(User) |> Repo.preload(:role)

team_assignments = [
  {1, [3, 4, 5]},
  {2, [6, 7]},
  {3, [8, 9]},
  {4, [10, 11, 12]}
]

for {team_index, user_ids} <- team_assignments do
  team_id = Enum.at(team_ids, team_index - 1)
  
  if team_id do
    for user_id <- user_ids do
      user = Enum.find(all_users, &(&1.id == user_id))
      
      if user do
        case Repo.get_by(TeamMembership, user_id: user_id, team_id: team_id) do
          nil ->
            case Repo.insert(TeamMembership.changeset(%TeamMembership{}, %{
              user_id: user_id,
              team_id: team_id
            })) do
              {:ok, _membership} -> :ok
              {:error, _changeset} -> :ok
            end
          _existing -> :ok
        end
      end
    end
  end
end

Agent.stop(counter)

# Task seeds
IO.puts("Creating sample tasks...")

# Get some users and teams for task assignment
all_users = Repo.all(User)
all_teams = Repo.all(Team)

# Ensure we have users and teams
if length(all_users) > 0 and length(all_teams) > 0 do
  # Get managers and employees
  managers = Enum.filter(all_users, fn user -> user.role_id == 2 end)
  employees = Enum.filter(all_users, fn user -> user.role_id == 1 end)
  
  # Get the first team
  team = List.first(all_teams)
  
  # Sample tasks
  sample_tasks = [
    %{
      title: "Complete quarterly report",
      description: "Prepare and submit the Q4 quarterly report with all metrics and analysis",
      status: "pending",
      priority: "high",
      due_date: ~D[2024-12-31],
      assigned_to_id: if(length(employees) > 0, do: Enum.at(employees, 0).id, else: nil),
      assigned_by_id: if(length(managers) > 0, do: Enum.at(managers, 0).id, else: nil),
      team_id: team.id
    },
    %{
      title: "Update project documentation",
      description: "Review and update all project documentation to reflect current status",
      status: "in_progress",
      priority: "medium",
      due_date: ~D[2024-12-20],
      assigned_to_id: if(length(employees) > 1, do: Enum.at(employees, 1).id, else: nil),
      assigned_by_id: if(length(managers) > 0, do: Enum.at(managers, 0).id, else: nil),
      team_id: team.id
    },
    %{
      title: "Code review for new feature",
      description: "Review the new authentication feature implementation and provide feedback",
      status: "pending",
      priority: "medium",
      due_date: ~D[2024-12-25],
      assigned_to_id: if(length(employees) > 2, do: Enum.at(employees, 2).id, else: nil),
      assigned_by_id: if(length(managers) > 1, do: Enum.at(managers, 1).id, else: nil),
      team_id: team.id
    },
    %{
      title: "Database optimization",
      description: "Analyze and optimize database queries for better performance",
      status: "completed",
      priority: "high",
      due_date: ~D[2024-12-15],
      assigned_to_id: if(length(employees) > 0, do: Enum.at(employees, 0).id, else: nil),
      assigned_by_id: if(length(managers) > 0, do: Enum.at(managers, 0).id, else: nil),
      team_id: team.id
    },
    %{
      title: "User interface testing",
      description: "Conduct comprehensive testing of the new user interface components",
      status: "pending",
      priority: "low",
      due_date: ~D[2024-12-30],
      assigned_to_id: if(length(employees) > 3, do: Enum.at(employees, 3).id, else: nil),
      assigned_by_id: if(length(managers) > 0, do: Enum.at(managers, 0).id, else: nil),
      team_id: team.id
    },
    %{
      title: "Security audit preparation",
      description: "Prepare all necessary documents and systems for the upcoming security audit",
      status: "in_progress",
      priority: "high",
      due_date: ~D[2024-12-22],
      assigned_to_id: if(length(employees) > 1, do: Enum.at(employees, 1).id, else: nil),
      assigned_by_id: if(length(managers) > 1, do: Enum.at(managers, 1).id, else: nil),
      team_id: team.id
    },
    %{
      title: "Team training session",
      description: "Organize and conduct training session for new team members",
      status: "pending",
      priority: "medium",
      due_date: ~D[2024-12-28],
      assigned_to_id: if(length(employees) > 4, do: Enum.at(employees, 4).id, else: nil),
      assigned_by_id: if(length(managers) > 0, do: Enum.at(managers, 0).id, else: nil),
      team_id: team.id
    },
    %{
      title: "Bug fixes for production",
      description: "Fix critical bugs reported in the production environment",
      status: "completed",
      priority: "high",
      due_date: ~D[2024-12-10],
      assigned_to_id: if(length(employees) > 2, do: Enum.at(employees, 2).id, else: nil),
      assigned_by_id: if(length(managers) > 0, do: Enum.at(managers, 0).id, else: nil),
      team_id: team.id
    }
  ]

  # Create tasks
  for task_data <- sample_tasks do
    case Repo.get_by(Task, title: task_data.title) do
      nil ->
        case TaskManagement.create_task(task_data) do
          {:ok, task} -> 
            IO.puts("Created task: #{task.title}")
          {:error, changeset} -> 
            IO.puts("Failed to create task: #{task_data.title}")
            IO.inspect(changeset.errors)
        end
      _existing_task ->
        IO.puts("Task already exists: #{task_data.title}")
    end
  end
else
  IO.puts("No users or teams found. Please run the main seeds first.")
end