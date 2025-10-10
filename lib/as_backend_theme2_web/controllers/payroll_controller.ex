defmodule AsBackendTheme2Web.PayrollController do
  use AsBackendTheme2Web, :controller
  alias AsBackendTheme2.TimeTracking

  @doc """
  GET /api/payroll/:user_id?start=YYYY-MM-DD&end=YYYY-MM-DD
  Returns totals, night hours, and weeks over 40h for a user.
  """
  def show(conn, %{"user_id" => user_id} = params) do
    # optional
    start_str = Map.get(params, "start")
    # optional
    end_str = Map.get(params, "end")

    summary = TimeTracking.payroll_summary(user_id, start_str, end_str)
    json(conn, summary)
  end
end
