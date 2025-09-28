# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     AsBackendTheme2.Repo.insert!(%AsBackendTheme2.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias AsBackendTheme2.Repo
alias AsBackendTheme2.Accounts.User
alias AsBackendTheme2.TimeTracking.WorkingTime
alias AsBackendTheme2.TimeTracking.Clock

# Create sample users for testing purposes
# Note: No roles are included as role logic is not yet implemented, we will implement roles via a Postgres read-only coumn that contains permissions for everyone
users = [
  # General Manager - has access to create users
  %{
    email: "admin@gotham.com",
    first_name: "Bruce",
    last_name: "Wayne"
  },
  # Manager - can view team data
  %{
    email: "manager@gotham.com",
    first_name: "Alfred",
    last_name: "Pennyworth"
  },
  # Regular employees with realistic data for graphs
  %{
    email: "john.doe@example.com",
    first_name: "John",
    last_name: "Doe"
  },
  %{
    email: "jane.smith@example.com",
    first_name: "Jane",
    last_name: "Smith"
  },
  %{
    email: "bob.wilson@example.com",
    first_name: "Bob",
    last_name: "Wilson"
  },
  %{
    email: "alice.brown@example.com",
    first_name: "Alice",
    last_name: "Brown"
  },
  %{
    email: "charlie.davis@example.com",
    first_name: "Charlie",
    last_name: "Davis"
  },
  %{
    email: "sarah.johnson@example.com",
    first_name: "Sarah",
    last_name: "Johnson"
  },
  %{
    email: "mike.garcia@example.com",
    first_name: "Mike",
    last_name: "Garcia"
  },
  %{
    email: "lisa.martinez@example.com",
    first_name: "Lisa",
    last_name: "Martinez"
  },
  %{
    email: "david.lee@example.com",
    first_name: "David",
    last_name: "Lee"
  },
  %{
    email: "emma.taylor@example.com",
    first_name: "Emma",
    last_name: "Taylor"
  }
]

# Insert users and collect their IDs with enhanced error handling
user_ids =
  for user_data <- users do
    case Repo.get_by(User, email: user_data.email) do
      nil ->
        case AsBackendTheme2.Accounts.create_user(user_data) do
          {:ok, user} ->
            IO.puts("✓ Created user: #{user_data.email} (ID: #{user.id})")
            user.id

          {:error, changeset} ->
            IO.puts("✗ Failed to create user #{user_data.email}")
            IO.puts("  Errors: #{inspect(changeset.errors)}")
            nil
        end

      existing_user ->
        IO.puts("→ User already exists: #{user_data.email} (ID: #{existing_user.id})")
        existing_user.id
    end
  end

# Filter out nil values if any from existing database entries
user_ids = Enum.filter(user_ids, &(&1 != nil))

IO.puts("\n📊 Created #{length(user_ids)} users successfully")

# Create realistic working times and clock data for each user (last 90 days)
# This will provide good data for graphs and analytics
IO.puts("\n⏰ Generating working times and clock data...")

# Use Agent to track counts across the loop
{:ok, counter} = Agent.start_link(fn -> %{working_time_count: 0, clock_count: 0} end)

# Define work patterns for different user types
work_patterns = [
  # Bruce Wayne (admin) - irregular hours, sometimes works late
  %{start_hour_range: {7, 10}, work_duration_range: {6, 12}, weekend_work_chance: 0.3},
  # Alfred (manager) - regular 9-5 with occasional overtime
  %{start_hour_range: {8, 9}, work_duration_range: {8, 10}, weekend_work_chance: 0.1},
  # Regular employees - mostly 9-5 with some variation
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
  # Get user info for more realistic data patterns
  user = Repo.get!(User, user_id)
  pattern = Enum.at(work_patterns, user_index) || Enum.at(work_patterns, 2) # Default to regular employee pattern
  IO.puts("  📝 Processing user: #{user.first_name} #{user.last_name} (#{user.email})")

  # Generate working times for the last 90 days for better graph data
  for day <- 0..89 do
    date = Date.add(Date.utc_today(), -day)

    # Skip weekends (Saturday = 6, Sunday = 7) for most users
    # But add some weekend work based on user pattern
    should_work = Date.day_of_week(date) in [1, 2, 3, 4, 5] or 
                  (:rand.uniform(100) <= (pattern.weekend_work_chance * 100))

    if should_work do
      # More realistic work patterns based on user type
      {min_start, max_start} = pattern.start_hour_range
      start_hour = :rand.uniform(max_start - min_start + 1) + min_start - 1

      # 0-59 minutes variation
      start_minute = :rand.uniform(60) - 1

      # Work duration based on pattern
      {min_duration, max_duration} = pattern.work_duration_range
      work_duration_hours = :rand.uniform(max_duration - min_duration + 1) + min_duration - 1

      end_hour = start_hour + work_duration_hours
      # Add 0-59 minutes variation
      end_minute = start_minute + :rand.uniform(60) - 1

      # Ensure end time doesn't go past 11 PM
      {end_hour, end_minute} =
        if end_hour >= 23 do
          {22, 59}
        else
          {end_hour, end_minute}
        end

      # Ensure end minute doesn't exceed 59
      {end_hour, end_minute} =
        if end_minute >= 60 do
          {end_hour + 1, end_minute - 60}
        else
          {end_hour, end_minute}
        end

      # Ensure end hour doesn't exceed 23 after minute adjustment
      {end_hour, end_minute} =
        if end_hour >= 24 do
          {23, 59}
        else
          {end_hour, end_minute}
        end

      start_time = NaiveDateTime.new!(date, Time.new!(start_hour, start_minute, 0))
      end_time = NaiveDateTime.new!(date, Time.new!(end_hour, end_minute, 0))

      # Create working time entry
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

              :ok

            {:error, changeset} ->
              IO.puts("    ✗ Failed to create working time for user #{user_id} on #{date}")
              IO.puts("      Errors: #{inspect(changeset.errors)}")
          end

        _existing ->
          :ok
      end

      # Create clock entries for the same day
      clock_in_time = NaiveDateTime.new!(date, Time.new!(start_hour, start_minute, 0))
      clock_out_time = NaiveDateTime.new!(date, Time.new!(end_hour, end_minute, 0))

      # Clock in
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

              :ok

            {:error, changeset} ->
              IO.puts("    ✗ Failed to create clock in for user #{user_id} on #{date}")
              IO.puts("      Errors: #{inspect(changeset.errors)}")
          end

        _existing ->
          :ok
      end

      # Clock out
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

              :ok

            {:error, changeset} ->
              IO.puts("    ✗ Failed to create clock out for user #{user_id} on #{date}")
              IO.puts("      Errors: #{inspect(changeset.errors)}")
          end

        _existing ->
          :ok
      end

      # Add some break entries for more realistic data (occasional clock out/in during the day)
      if work_duration_hours >= 6 and :rand.uniform(3) == 1 do
        # Lunch break - clock out for 30-60 minutes
        break_start_hour = start_hour + 4
        break_start_minute = start_minute + :rand.uniform(30)
        break_end_hour = break_start_hour
        break_end_minute = break_start_minute + 30 + :rand.uniform(30)

        # Ensure break times are valid
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

        # Ensure break times are within valid range (0-23 hours, 0-59 minutes)
        break_start_hour = min(break_start_hour, 23)
        break_end_hour = min(break_end_hour, 23)
        break_start_minute = min(break_start_minute, 59)
        break_end_minute = min(break_end_minute, 59)

        # Ensure break doesn't go past end time
        if break_end_hour < end_hour or (break_end_hour == end_hour and break_end_minute < end_minute) do
          break_start_time = NaiveDateTime.new!(date, Time.new!(break_start_hour, break_start_minute, 0))
          break_end_time = NaiveDateTime.new!(date, Time.new!(break_end_hour, break_end_minute, 0))

          # Break clock out
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

          # Break clock in
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