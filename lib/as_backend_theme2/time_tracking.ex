defmodule AsBackendTheme2.TimeTracking do
  @moduledoc """
  The TimeTracking context provides functions for managing working times and clock in/out functionality.

  This module handles:
  - Working time entries (start/end times for work sessions)
  - Clock in/out tracking (boolean status tracking)
  - Automatic working time creation when clocking out

  Clock Convention:
  - status: true = User is clocked in (working)
  - status: false = User is clocked out (not working)
  - Toggle logic: if last entry is true (clocked in) → next action is clock out (false)
  - Toggle logic: if last entry is false or no entry → next action is clock in (true)
  """

  import Ecto.Query, warn: false
  alias AsBackendTheme2.Repo
  alias AsBackendTheme2.Accounts.User

  alias AsBackendTheme2.TimeTracking.WorkingTime

  # ============================================================================
  # WORKING TIME MANAGEMENT FUNCTIONS
  # ============================================================================

  @doc """
  Retrieves working time entries for a specific user with optional date filtering.

  ## Parameters
  - `user_id`: String or integer user ID
  - `start_date`: Optional start date filter (ISO8601 string)
  - `end_dt`: Optional end date filter (ISO8601 string)

  ## Returns
  List of working time entries ordered by start time
  """
  def list_working_times_by_user(user_id, start_date, end_dt) do
    uid =
      case user_id do
        i when is_integer(i) -> i
        bin when is_binary(bin) -> String.to_integer(bin)
      end

    base_query =
      from wt in WorkingTime,
        where: wt.user_id == ^uid

    query =
      cond do
        start_date && end_dt ->
          from wt in base_query,
            where:
              wt.start >= ^parse_datetime(start_date) and
                wt.end <= ^parse_datetime(end_dt)

        true ->
          base_query
      end

    Repo.all(query)
  end

  # ---------- Payroll summary (totals, night hours, weekly overtime) -------------

  @doc """
  Compute a payroll summary for a user over an optional date range.

  Params:
  - user_id: integer or string
  - start_str: optional "YYYY-MM-DD" or "YYYY-MM-DD HH:MM:SS"
  - end_str:   optional "YYYY-MM-DD" or "YYYY-MM-DD HH:MM:SS"

  Returns a map:
  %{
    user_id: 1,
    start: "2025-10-01",
    end: "2025-10-07",
    total_hours: 43.5,
    night_hours: 12.0,
    overtime: true,
    overtime_weeks: ["2025-W41"],
    weekly_hours: %{"2025-W41" => 43.5}
  }
  """
  def payroll_summary(user_id, start_str \\ nil, end_str \\ nil) do
    user_id = to_int(user_id)
    {start_ndt, end_ndt} = parse_range(start_str, end_str)

    base =
      from wt in WorkingTime,
        where: wt.user_id == ^user_id

    q =
      base
      |> maybe_from(start_ndt)
      |> maybe_to(end_ndt)

    records = Repo.all(q)

    {total_hours, night_hours, weekly_hours} =
      Enum.reduce(records, {0.0, 0.0, %{}}, fn wt, {tot, night, weeks} ->
        dur_h = duration_hours(wt.start, wt.end)
        tot2 = tot + dur_h
        night2 = if wt.shift_type == "night", do: night + dur_h, else: night

        date = NaiveDateTime.to_date(wt.start)
        {week, week_year} = :calendar.iso_week_number({date.year, date.month, date.day})
        key = "#{week_year}-W" <> String.pad_leading(Integer.to_string(week), 2, "0")
        weeks2 = Map.update(weeks, key, dur_h, &(&1 + dur_h))

        {tot2, night2, weeks2}
      end)

    overtime_weeks =
      weekly_hours
      |> Enum.filter(fn {_w, h} -> h > 40.0 end)
      |> Enum.map(&elem(&1, 0))

    %{
      user_id: user_id,
      start: start_str,
      end: end_str,
      total_hours: round2(total_hours),
      night_hours: round2(night_hours),
      overtime: overtime_weeks != [],
      overtime_weeks: overtime_weeks,
      weekly_hours: Enum.into(weekly_hours, %{}, fn {k, v} -> {k, round2(v)} end)
    }
  end

  # ------------------------------ helpers --------------------------------------

  defp duration_hours(%NaiveDateTime{} = s, %NaiveDateTime{} = e) do
    secs = NaiveDateTime.diff(e, s, :second)
    max(secs, 0) / 3600.0
  end

  defp round2(f) when is_float(f), do: Float.round(f, 2)
  defp round2(x), do: x

  defp to_int(v) when is_integer(v), do: v

  defp to_int(v) when is_binary(v) do
    case Integer.parse(v) do
      {i, ""} -> i
      _ -> raise ArgumentError, "user_id must be integer-like, got: #{inspect(v)}"
    end
  end

  defp parse_range(nil, nil), do: {nil, nil}

  defp parse_range(start_str, end_str) do
    {parse_maybe_date_or_dt(start_str, :start), parse_maybe_date_or_dt(end_str, :end)}
  end

  # Accepts:
  #  - "YYYY-MM-DD"  (expanded to start-of-day / end-of-day)
  #  - "YYYY-MM-DD HH:MM:SS"
  #  - ISO-like strings with "T"
  defp parse_maybe_date_or_dt(nil, _kind), do: nil

  defp parse_maybe_date_or_dt(str, kind) when is_binary(str) do
    s = String.replace(str, "T", " ")

    s =
      case String.length(s) do
        10 -> s <> if(kind == :start, do: " 00:00:00", else: " 23:59:59")
        _ -> s
      end

    case NaiveDateTime.from_iso8601(s) do
      {:ok, ndt} -> ndt
      _ -> nil
    end
  end

  # Accepts:
  #  - "YYYY-MM-DD"  (we expand to start-of-day / end-of-day)
  #  - "YYYY-MM-DD HH:MM:SS"
  #  - ISO-like with "T"
  defp parse_maybe_date_or_dt(nil, _kind), do: nil

  defp parse_maybe_date_or_dt(str, kind) when is_binary(str) do
    s = String.replace(str, "T", " ")

    s =
      case String.length(s) do
        10 -> s <> if(kind == :start, do: " 00:00:00", else: " 23:59:59")
        _ -> s
      end

    case NaiveDateTime.from_iso8601(s) do
      {:ok, ndt} -> ndt
      _ -> nil
    end
  end

  defp maybe_from(query, nil), do: query

  defp maybe_from(query, %NaiveDateTime{} = ndt),
    do: from(wt in query, where: wt.start >= ^ndt)

  defp maybe_to(query, nil), do: query

  defp maybe_to(query, %NaiveDateTime{} = ndt),
    do: from(wt in query, where: wt.end <= ^ndt)

  @doc """
  Gets a specific working time entry for a user.

  ## Parameters
  - `id`: Working time entry ID
  - `user_id`: User ID to ensure ownership

  ## Returns
  Working time entry or nil if not found
  """
  def get_working_time_by_user(id, user_id) do
    from(wt in WorkingTime,
      where: wt.id == ^id and wt.user_id == ^user_id
    )
    |> Repo.one()
  end

  @doc """
  Gets a working time entry by ID (for admin operations).

  ## Parameters
  - `id`: Working time entry ID

  ## Returns
  Working time entry or nil if not found
  """
  def get_working_time(id), do: Repo.get(WorkingTime, id)

  @doc """
  Creates a new working time entry.

  ## Parameters
  - `attrs`: Map containing start, end, and user_id

  ## Returns
  {:ok, working_time} or {:error, changeset}
  """
  def create_working_time(attrs \\ %{}) do
    %WorkingTime{}
    |> WorkingTime.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates an existing working time entry.

  ## Parameters
  - `working_time`: Working time struct to update
  - `attrs`: Map containing new attributes

  ## Returns
  {:ok, working_time} or {:error, changeset}
  """
  def update_working_time(%WorkingTime{} = working_time, attrs) do
    working_time
    |> WorkingTime.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a working time entry.

  ## Parameters
  - `working_time`: Working time struct to delete

  ## Returns
  {:ok, working_time} or {:error, changeset}
  """
  def delete_working_time(%WorkingTime{} = working_time) do
    Repo.delete(working_time)
  end

  @doc """
  Gets a working time entry by ID and raises if not found.

  ## Parameters
  - `id`: Working time entry ID

  ## Returns
  Working time entry or raises Ecto.NoResultsError
  """
  def get_working_time!(id), do: Repo.get!(WorkingTime, id)

  @doc """
  Lists all working time entries.

  ## Returns
  List of all working time entries
  """
  def list_working_times do
    Repo.all(WorkingTime)
  end

  @doc """
  Returns a changeset for working time changes.

  ## Parameters
  - `working_time`: Working time struct

  ## Returns
  Ecto.Changeset
  """
  def change_working_time(%WorkingTime{} = working_time, attrs \\ %{}) do
    WorkingTime.changeset(working_time, attrs)
  end

  # Helper function to parse datetime safely
  defp parse_datetime(nil), do: nil

  defp parse_datetime(str) do
    str
    |> String.replace("T", " ")
    |> NaiveDateTime.from_iso8601()
    |> case do
      {:ok, dt} -> dt
      # fallback dummy date
      _ -> ~N[1900-01-01 00:00:00]
    end
  end

  alias AsBackendTheme2.TimeTracking.Clock

  # ============================================================================
  # CLOCK IN/OUT MANAGEMENT FUNCTIONS
  # ============================================================================

  @doc """
  Retrieves all clock entries for a specific user, ordered by most recent first.

  ## Parameters
  - `user_id`: String or integer user ID

  ## Returns
  List of clock entries ordered by time (descending)
  """
  def list_clocks_for_user(user_id) do
    case Integer.parse(to_string(user_id)) do
      {id, ""} ->
        from(c in Clock,
          where: c.user_id == ^id,
          order_by: [desc: c.time]
        )
        |> Repo.all()

      _ ->
        []
    end
  end

  @doc """
  Gets the most recent clock entry for a user.

  ## Parameters
  - `user_id`: Integer or string user ID

  ## Returns
  Clock entry or nil if no entries exist or invalid ID
  """
  def get_last_clock(user_id) when is_integer(user_id) do
    from(c in Clock,
      where: c.user_id == ^user_id,
      order_by: [desc: c.id],
      limit: 1
    )
    |> Repo.one()
  end

  def get_last_clock(user_id) when is_binary(user_id) do
    case Integer.parse(user_id) do
      {id, ""} -> get_last_clock(id)
      _ -> nil
    end
  end

  @doc """
  Creates a new clock entry.

  ## Parameters
  - `attrs`: Map containing time, status, and user_id

  ## Returns
  {:ok, clock} or {:error, changeset}
  """
  def create_clock(attrs \\ %{}) do
    %Clock{}
    |> Clock.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Toggles clock in/out status for a user.

  This is the main function for clock in/out functionality:
  - If user is currently clocked out (status: false) or has no entries → clocks in (status: true)
  - If user is currently clocked in (status: true) → clocks out (status: false)
  - When clocking out, automatically creates a working time entry

  ## Parameters
  - `user_id_str`: String user ID

  ## Returns
  {:ok, clock} or {:error, reason}

  ## Clock Convention
  - status: true = User is clocked in (working)
  - status: false = User is clocked out (not working)
  """
  def toggle_clock_for_user(user_id_str) do
    case Integer.parse(user_id_str) do
      {user_id, ""} ->
        # Verify user exists
        case Repo.get(AsBackendTheme2.Accounts.User, user_id) do
          nil ->
            {:error, "User not found"}

          _user ->
            last_clock = get_last_clock(user_id)
            current_time = NaiveDateTime.utc_now()

            # Determine next status based on last clock entry
            status =
              case last_clock do
                # Was clocked in, now clock out
                %Clock{status: true} -> false
                # Was clocked out or no entry, now clock in
                _ -> true
              end

            clock_attrs = %{
              "time" => current_time,
              "status" => status,
              "user_id" => user_id
            }

            case %Clock{}
                 |> Clock.changeset(clock_attrs)
                 |> Repo.insert() do
              {:ok, clock} ->
                # If we're clocking out, create a working time entry
                if status == false and last_clock && last_clock.status == true do
                  working_time_attrs = %{
                    "start" => last_clock.time,
                    "end" => current_time,
                    "user_id" => user_id
                  }

                  # Create working time entry (ignore result for now)
                  %WorkingTime{}
                  |> WorkingTime.changeset(working_time_attrs)
                  |> Repo.insert()
                end

                {:ok, clock}

              error ->
                error
            end
        end

      _ ->
        {:error, "Invalid user ID"}
    end
  end

  @doc """
  Gets a clock entry by ID and raises if not found.

  ## Parameters
  - `id`: Clock entry ID

  ## Returns
  Clock entry or raises Ecto.NoResultsError
  """
  def get_clock!(id), do: Repo.get!(Clock, id)

  @doc """
  Lists all clock entries.

  ## Returns
  List of all clock entries
  """
  def list_clocks do
    Repo.all(Clock)
  end

  @doc """
  Updates an existing clock entry.

  ## Parameters
  - `clock`: Clock struct to update
  - `attrs`: Map containing new attributes

  ## Returns
  {:ok, clock} or {:error, changeset}
  """
  def update_clock(%Clock{} = clock, attrs) do
    clock
    |> Clock.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a clock entry.

  ## Parameters
  - `clock`: Clock struct to delete

  ## Returns
  {:ok, clock} or {:error, changeset}
  """
  def delete_clock(%Clock{} = clock) do
    Repo.delete(clock)
  end

  @doc """
  Returns a changeset for clock changes.

  ## Parameters
  - `clock`: Clock struct

  ## Returns
  Ecto.Changeset
  """
  def change_clock(%Clock{} = clock, attrs \\ %{}) do
    Clock.changeset(clock, attrs)
  end

  @doc """
  Returns a list of employees and managers who are currently clocked in (not clocked out yet).

  Logic:
  - For each user, find their latest clock record.
  - If the latest record has `status = true`, they are currently clocked in.
  - Only include users whose role is 'Employee' or 'Manager'.
  """
  def users_not_clocked_out do
    alias AsBackendTheme2.Accounts.{User, Role}
    alias AsBackendTheme2.TimeTracking.Clock
    import Ecto.Query, warn: false
    alias AsBackendTheme2.Repo

    # Step 1: Get latest clock time per user
    latest_clock_per_user =
      from(c in Clock,
        select: %{user_id: c.user_id, latest_time: max(c.time)},
        group_by: c.user_id
      )

    # Step 2: Join with users + roles, only include employees/managers whose latest clock has status = true
    query =
      from(u in User,
        join: lc in subquery(latest_clock_per_user),
        on: u.id == lc.user_id,
        join: c in Clock,
        on: c.user_id == lc.user_id and c.time == lc.latest_time,
        join: r in Role,
        on: r.id == u.role_id,
        where: c.status == true and r.name in ["employee", "manager"],
        select: %{id: u.id, email: u.email, role: r.name}
      )

    Repo.all(query)
  end
end
