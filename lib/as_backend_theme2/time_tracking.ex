defmodule AsBackendTheme2.TimeTracking do
  @moduledoc """
  The TimeTracking context.
  """

  import Ecto.Query, warn: false
  alias AsBackendTheme2.Repo

  alias AsBackendTheme2.TimeTracking.WorkingTime

  # GET /api/workingtime/:userID?start=...&end=...
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

  # GET /api/workingtime/:userID/:id
  def get_working_time_by_user(id, user_id) do
    from(wt in WorkingTime,
      where: wt.id == ^id and wt.user_id == ^user_id
    )
    |> Repo.one()
  end

  # GET /api/workingtime/:id (for PUT/DELETE)
  def get_working_time(id), do: Repo.get(WorkingTime, id)

  # POST /api/workingtime/:userID
  def create_working_time(attrs \\ %{}) do
    %WorkingTime{}
    |> WorkingTime.changeset(attrs)
    |> Repo.insert()
  end

  # PUT /api/workingtime/:id
  def update_working_time(%WorkingTime{} = working_time, attrs) do
    working_time
    |> WorkingTime.changeset(attrs)
    |> Repo.update()
  end

  # DELETE /api/workingtime/:id
  def delete_working_time(%WorkingTime{} = working_time) do
    Repo.delete(working_time)
  end

  # Helper function to parse datetime safely
  defp parse_datetime(nil), do: nil

  defp parse_datetime(str) do
    str
    |> String.replace("T", " ")
    |> NaiveDateTime.from_iso8601()
    |> case do
      {:ok, dt} -> dt
      _ -> ~N[1900-01-01 00:00:00] # fallback dummy date
    end
  end

  alias AsBackendTheme2.TimeTracking.Clock

  # Get all clocks for a user
  def list_clocks_for_user(user_id) do
    from(c in Clock,
      where: c.user_id == ^String.to_integer(user_id),
      order_by: [desc: c.time]
    )
    |> Repo.all()
  end

  # Get the most recent clock entry for a user
  def get_last_clock(user_id) do
    from(c in Clock,
      where: c.user_id == ^String.to_integer(user_id),
      order_by: [desc: c.time],
      limit: 1
    )
    |> Repo.one()
  end

  # Toggle clock-in / clock-out
  def toggle_clock_for_user(user_id_str) do
    case Integer.parse(user_id_str) do
      {user_id, ""} ->
        # check if user exists
        case Repo.get(AsBackendTheme2.Accounts.User, user_id) do
          nil ->
            {:error, "User not found"}

          _user ->
            status =
              case get_last_clock(user_id) do
                %Clock{status: true} -> false
                _ -> true
              end

            attrs = %{
              "time" => NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
              "status" => status,
              "user_id" => user_id
            }

            %Clock{}
            |> Clock.changeset(attrs)
            |> Repo.insert()
        end

      _ ->
        {:error, "Invalid user ID"}
    end
  end



end
