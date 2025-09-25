defmodule AsBackendTheme2Web.ClockController do
  use AsBackendTheme2Web, :controller

  alias AsBackendTheme2.TimeTracking
  alias AsBackendTheme2.TimeTracking.Clock

  # GET /api/clocks/:userID
  def index_by_user(conn, %{"userID" => user_id}) do
    clocks = TimeTracking.list_clocks_for_user(user_id)
    json(conn, clocks)
  end

  # POST /api/clocks/:userID
  def toggle(conn, %{"userID" => user_id}) do
    case TimeTracking.toggle_clock_for_user(user_id) do
      {:ok, clock} ->
        conn
        |> put_status(:created)
        |> render(:show, clock: clock)

      {:error, reason} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: reason})
    end
  end

end
