defmodule AsBackendTheme2Web.WorkingTimeController do
  @moduledoc """
  Controller for handling working time operations.

  This controller provides REST API endpoints for:
  - Retrieving working time entries for a user
  - Creating, updating, and deleting working time entries
  - Filtering working times by date range

  Working times are automatically created when users clock out,
  but can also be manually created, updated, or deleted.
  """

  use AsBackendTheme2Web, :controller

  alias AsBackendTheme2.TimeTracking

  action_fallback AsBackendTheme2Web.FallbackController

  @doc """
  Retrieves working time entries for a specific user with optional date filtering.

  ## Route
  GET /api/workingtime/:userID?start=...&end=...

  ## Parameters
  - `user_id`: User ID in the URL path
  - `start`: Optional start date filter (ISO8601 string)
  - `end`: Optional end date filter (ISO8601 string)

  ## Returns
  JSON response with array of working time entries
  """
  def index_by_user(conn, %{"userID" => user_id} = params) do
    working_times =
      TimeTracking.list_working_times_by_user(user_id, params["start"], params["end"])

    render(conn, :index, working_times: working_times)
  end

  @doc """
  Retrieves a specific working time entry for a user.

  ## Route
  GET /api/workingtime/:userID/:id

  ## Parameters
  - `user_id`: User ID in the URL path
  - `id`: Working time entry ID

  ## Returns
  JSON response with working time entry or error
  """
  def show_one(conn, %{"userID" => user_id_str, "id" => id_str}) do
    case {Integer.parse(user_id_str), Integer.parse(id_str)} do
      {{user_id, ""}, {working_time_id, ""}} ->
        working_time = TimeTracking.get_working_time!(working_time_id)

        # Verify the working time belongs to the user
        if working_time.user_id == user_id do
          conn
          |> put_status(:ok)
          |> render(:show, working_time: working_time)
        else
          {:error, :not_found}
        end

      _ ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Invalid user ID or working time ID"})
    end
  end

  @doc """
  Creates a new working time entry for a user.

  ## Route
  POST /api/workingtime/:userID

  ## Parameters
  - `user_id`: User ID in the URL path
  - `working_time`: Map containing start, end times

  ## Returns
  JSON response with created working time entry or error
  """
  def create_for_user(conn, %{"userID" => user_id} = params) do
    attrs = Map.put(params["working_time"] || %{}, "user_id", user_id)

    case TimeTracking.create_working_time(attrs) do
      {:ok, working_time} ->
        conn
        |> put_status(:created)
        |> render(:show, working_time: working_time)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(json: AsBackendTheme2Web.WorkingTimeJSON)
        |> render(:error, changeset: changeset)
    end
  end

  @doc """
  Updates an existing working time entry.

  ## Route
  PUT /api/workingtime/:id

  ## Parameters
  - `id`: Working time entry ID
  - `working_time`: Map containing updated attributes

  ## Returns
  JSON response with updated working time entry or error
  """
  def update(conn, %{"id" => id, "working_time" => wt_params}) do
    case TimeTracking.get_working_time(id) do
      nil ->
        send_resp(conn, 404, "Not found")

      working_time ->
        case TimeTracking.update_working_time(working_time, wt_params) do
          {:ok, wt} ->
            render(conn, :show, working_time: wt)

          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> put_view(json: AsBackendTheme2Web.WorkingTimeJSON)
            |> render(:error, changeset: changeset)
        end
    end
  end

  @doc """
  Deletes a working time entry.

  ## Route
  DELETE /api/workingtime/:id

  ## Parameters
  - `id`: Working time entry ID

  ## Returns
  204 No Content on success, 404 Not Found if entry doesn't exist
  """
  def delete(conn, %{"id" => id}) do
    case TimeTracking.get_working_time(id) do
      nil ->
        send_resp(conn, 404, "Not found")

      wt ->
        {:ok, _} = TimeTracking.delete_working_time(wt)
        send_resp(conn, 204, "")
    end
  end
end
