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
    base_query =
      from wt in WorkingTime,
        where: wt.user_id == ^String.to_integer(user_id)

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
                if (status == false and last_clock) && last_clock.status == true do
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
end
