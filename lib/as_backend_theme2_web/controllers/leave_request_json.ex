defmodule AsBackendTheme2Web.LeaveRequestJSON do
  alias AsBackendTheme2.Leaves.LeaveRequest

  def index(%{leaves: leaves}) do
    %{data: for(leave <- leaves, do: data(leave))}
  end

  def show(%{leave_request: leave}) do
    %{data: data(leave)}
  end

  defp data(%LeaveRequest{} = leave) do
    %{
      id: leave.id,
      leave_type: leave.leave_type,
      start_date: leave.start_date,
      end_date: leave.end_date,
      reason: leave.reason,
      status: leave.status,
      user_id: leave.user_id
    }
  end
end
