defmodule AsBackendTheme2.Leaves do
  @moduledoc """
  Context for handling leave requests with role-based visibility.
  """

  import Ecto.Query, warn: false
  alias AsBackendTheme2.Repo
  alias AsBackendTheme2.Leaves.LeaveRequest
  alias AsBackendTheme2.Accounts

  # --------------------------------------------------------------------
  # 1. CREATE LEAVE REQUEST (employee creates for themself)
  # --------------------------------------------------------------------
  @doc """
  Creates a new leave request for the given user.

  We inject the `user_id` from the JWT so that the client
  cannot forge requests on behalf of someone else.
  """
  def create_leave(user_id, attrs \\ %{}) do
    attrs = Map.put(attrs, "user_id", user_id)

    %LeaveRequest{}
    |> LeaveRequest.changeset(attrs)
    |> Repo.insert()
  end

  # --------------------------------------------------------------------
  # 2. FETCHING LEAVES WITH ROLE LOGIC
  # --------------------------------------------------------------------

  @doc """
  Returns a list of leave requests visible to the given user,
  optionally filtered by `status` (e.g., "Pending", "Approved", "Rejected").
  """
  def list_visible_leaves(current_user, status \\ nil) do
    base_query =
      case current_user.role.name do
        "Employee" ->
          from(l in LeaveRequest, where: l.user_id == ^current_user.id)

        "Manager" ->
          team_user_ids = Accounts.get_team_user_ids(current_user.id)
          from(l in LeaveRequest, where: l.user_id in ^team_user_ids)

        "Admin" ->
          from(l in LeaveRequest)

        _ ->
          from(l in LeaveRequest, where: false)
      end

    # Optional filter by status
    query =
      if status do
        from(l in base_query, where: l.status == ^status)
      else
        base_query
      end

    Repo.all(from(l in query, order_by: [desc: l.inserted_at]))
  end

  # --------------------------------------------------------------------
  # 3. HELPER FUNCTIONS USED ABOVE
  # --------------------------------------------------------------------

  # Employee: only their own leaves
  def list_user_leaves(user_id) do
    from(l in LeaveRequest,
      where: l.user_id == ^user_id,
      order_by: [desc: l.inserted_at]
    )
    |> Repo.all()
  end

  # Manager: all leaves of a given list of user ids
  def list_leaves_for_users(user_ids) when is_list(user_ids) do
    from(l in LeaveRequest,
      where: l.user_id in ^user_ids,
      order_by: [desc: l.inserted_at]
    )
    |> Repo.all()
  end

  # Admin: all leaves in the system
  def list_all_leaves do
    from(l in LeaveRequest, order_by: [desc: l.inserted_at])
    |> Repo.all()
  end

  @doc """
  Gets a single leave request if the current user is allowed to view it.

  - Employee → can only view their own leaves
  - Manager  → can view leaves of team members
  - Admin    → can view any leave
  """
  def get_visible_leave!(current_user, leave_id) do
    alias AsBackendTheme2.Accounts
    import Ecto.Query, warn: false
    alias AsBackendTheme2.Repo
    alias AsBackendTheme2.Leaves.LeaveRequest

    case current_user.role.name do
      "Employee" ->
        from(l in LeaveRequest,
          where: l.id == ^leave_id and l.user_id == ^current_user.id
        )
        |> Repo.one!()

      "Manager" ->
        team_user_ids = Accounts.get_team_user_ids(current_user.id)

        from(l in LeaveRequest,
          where: l.id == ^leave_id and l.user_id in ^team_user_ids
        )
        |> Repo.one!()

      "Admin" ->
        Repo.get!(LeaveRequest, leave_id)

      _ ->
        raise Ecto.NoResultsError, message: "Unauthorized or not found"
    end
  end

  # ==========================================================
  # APPROVE / REJECT LEAVES — respecting static roles
  # ==========================================================
  @doc """
  Approves a leave request according to fixed role hierarchy:
  - Manager → can approve team members (employees)
  - Admin   → can approve managers
  """
  def approve_leave(current_user, leave_id) do
    update_leave_status(current_user, leave_id, "Approved")
  end

  @doc """
  Rejects a leave request according to fixed role hierarchy:
  - Manager → can reject team members (employees)
  - Admin   → can reject managers
  """
  def reject_leave(current_user, leave_id) do
    update_leave_status(current_user, leave_id, "Rejected")
  end

  defp update_leave_status(current_user, leave_id, new_status) do
    alias AsBackendTheme2.Accounts
    import Ecto.Query, warn: false
    alias AsBackendTheme2.{Repo, Leaves.LeaveRequest}

    role_name = String.downcase(current_user.role.name)

    case role_name do
      "manager" ->
        # Managers can approve/reject leaves of employees in their team
        team_user_ids = Accounts.get_team_user_ids(current_user.id)

        leave =
          from(l in LeaveRequest,
            join: u in assoc(l, :user),
            join: r in assoc(u, :role),
            where:
              l.id == ^leave_id and
                l.user_id in ^team_user_ids and
                r.name == "Employee",
            preload: [user: [:role]]
          )
          |> Repo.one()

        maybe_update_status(leave, new_status)

      "admin" ->
        # Admins can approve/reject leaves of managers only
        leave =
          from(l in LeaveRequest,
            join: u in assoc(l, :user),
            join: r in assoc(u, :role),
            where: l.id == ^leave_id and r.name == "Manager",
            preload: [user: [:role]]
          )
          |> Repo.one()

        maybe_update_status(leave, new_status)

      _ ->
        #  Employees and others not allowed
        {:error, :unauthorized}
    end
  end

  defp maybe_update_status(nil, _new_status), do: {:error, :unauthorized}

  defp maybe_update_status(%AsBackendTheme2.Leaves.LeaveRequest{} = leave, new_status) do
    leave
    |> Ecto.Changeset.change(status: new_status)
    |> AsBackendTheme2.Repo.update()
  end
end
