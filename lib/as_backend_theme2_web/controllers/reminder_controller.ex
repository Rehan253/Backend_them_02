defmodule AsBackendTheme2Web.ReminderController do
  use AsBackendTheme2Web, :controller
  alias AsBackendTheme2.TimeTracking

  @doc """
  GET /api/reminder/not-clocked-out
  Returns all employees/managers currently clocked in (not clocked out yet).
  """
  def not_clocked_out(conn, _params) do
    users = TimeTracking.users_not_clocked_out()
    json(conn, %{data: users})
  end
end
