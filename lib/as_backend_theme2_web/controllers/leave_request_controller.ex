defmodule AsBackendTheme2Web.LeaveRequestController do
  use AsBackendTheme2Web, :controller
  alias AsBackendTheme2.Leaves
  alias AsBackendTheme2.Leaves.LeaveRequest

  action_fallback AsBackendTheme2Web.FallbackController

  # ------------------------------------------------------------------
  # 1. LIST visible leaves
  # ------------------------------------------------------------------
  @doc """
  Lists leaves visible to the logged-in user.
  - Employee -> only their own
  - Manager  -> team members
  - Admin    -> all
  """
  def index(conn, params) do
    current_user = conn.assigns.current_user
    # optional ?status=Pending
    status = Map.get(params, "status")
    leaves = Leaves.list_visible_leaves(current_user, status)
    render(conn, :index, leaves: leaves)
  end

  # ------------------------------------------------------------------
  # 2. CREATE a new leave (for the logged-in user)
  # ------------------------------------------------------------------
  @doc """
  Creates a new leave request for the current user.
  The user_id is taken from JWT, not from request body.
  """
  def create(conn, %{"leave_request" => leave_params}) do
    current_user = conn.assigns.current_user

    cond do
      current_user.role.name == "admin" ->
        conn
        |> put_status(:forbidden)
        |> json(%{error: "Admins cannot request leaves"})

      current_user.role.name in ["employee", "manager"] ->
        case Leaves.create_leave(current_user.id, leave_params) do
          {:ok, %LeaveRequest{} = leave} ->
            conn
            |> put_status(:created)
            |> render(:show, leave_request: leave)

          {:error, %Ecto.Changeset{} = changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> render(AsBackendTheme2Web.ChangesetJSON, changeset: changeset)
        end

      true ->
        conn
        |> put_status(:forbidden)
        |> json(%{error: "Unauthorized role"})
    end
  end

  # ------------------------------------------------------------------
  # (Optional) 3. SHOW a specific leave (belonging to user/team)
  # ------------------------------------------------------------------
  def show(conn, %{"id" => id}) do
    current_user = conn.assigns.current_user
    leave = Leaves.get_visible_leave!(current_user, id)
    render(conn, :show, leave_request: leave)
  end

  # ==========================================================
  # APPROVE a leave request (Manager/Admin only)
  # ==========================================================
  def approve(conn, %{"id" => id}) do
    current_user = conn.assigns.current_user

    case Leaves.approve_leave(current_user, id) do
      {:ok, leave} ->
        render(conn, :show, leave_request: leave)

      {:error, :unauthorized} ->
        conn
        |> put_status(:forbidden)
        |> json(%{error: "You are not allowed to approve this leave"})

      {:error, _} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Failed to approve leave"})
    end
  end

  # ==========================================================
  # REJECT a leave request (Manager/Admin only)
  # ==========================================================
  def reject(conn, %{"id" => id}) do
    current_user = conn.assigns.current_user

    case Leaves.reject_leave(current_user, id) do
      {:ok, leave} ->
        render(conn, :show, leave_request: leave)

      {:error, :unauthorized} ->
        conn
        |> put_status(:forbidden)
        |> json(%{error: "You are not allowed to reject this leave"})

      {:error, _} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Failed to reject leave"})
    end
  end
end
