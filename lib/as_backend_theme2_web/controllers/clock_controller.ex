defmodule AsBackendTheme2Web.ClockController do
  @moduledoc """
  Controller for handling clock in/out operations.

  This controller provides REST API endpoints for:
  - Retrieving clock entries for a user
  - Toggling clock in/out status

  Clock Convention:
  - status: true = User is clocked in (working)
  - status: false = User is clocked out (not working)
  """

  use AsBackendTheme2Web, :controller

  alias AsBackendTheme2.TimeTracking

  @doc """
  Retrieves all clock entries for a specific user.

  ## Route
  GET /api/clocks/:userID

  ## Parameters
  - `user_id`: User ID in the URL path

  ## Returns
  JSON response with array of clock entries
  """
  def index_by_user(conn, %{"userID" => user_id}) do
    clocks = TimeTracking.list_clocks_for_user(user_id)

    conn
    |> put_view(json: AsBackendTheme2Web.ClockJSON)
    |> render(:index, clocks: clocks)
  end

  @doc """
  Toggles clock in/out status for a user.

  This is the main endpoint for clock in/out functionality:
  - If user is currently clocked out → clocks in (status: true)
  - If user is currently clocked in → clocks out (status: false)
  - When clocking out, automatically creates a working time entry

  ## Route
  POST /api/clocks/:userID

  ## Parameters
  - `user_id`: User ID in the URL path

  ## Returns
  JSON response with the new clock entry or error message
  """
  def toggle(conn, %{"userID" => user_id}) do
    case TimeTracking.toggle_clock_for_user(user_id) do
      {:ok, clock} ->
        conn
        |> put_status(:created)
        |> put_view(json: AsBackendTheme2Web.ClockJSON)
        |> render(:show, clock: clock)

      {:error, reason} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: reason})
    end
  end
end
