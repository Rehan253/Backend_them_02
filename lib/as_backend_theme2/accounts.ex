defmodule AsBackendTheme2.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias AsBackendTheme2.Repo

  alias AsBackendTheme2.Accounts.User
  alias AsBackendTheme2.TimeTracking.WorkingTime
  alias AsBackendTheme2.TimeTracking.Clock
  alias AsBackendTheme2.Accounts.TeamMembership

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User) |> Repo.preload(:role)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id) do
    User
    |> Repo.get!(id)
    |> Repo.preload(:role)
  end

  @doc """
  Gets a single user by email.

  Returns `nil` if the User does not exist.

  ## Examples

      iex> get_user_by_email("user@example.com")
      %User{}

      iex> get_user_by_email("nonexistent@example.com")
      nil

  """
  def get_user_by_email(email) do
    Repo.get_by(User, email: email)
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """

  def create_user(attrs) do
    email = Map.get(attrs, "email")

    cond do
      is_nil(email) ->
        %User{}
        |> User.registration_changeset(attrs)
        |> Repo.insert()

      get_user_by_email(email) ->
        {:error, %Ecto.Changeset{} |> Ecto.Changeset.add_error(:email, "has already been taken")}

      true ->
        %User{}
        |> User.registration_changeset(attrs)
        |> Repo.insert()
    end
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.transaction(fn ->
      # Delete all working times for this user
      from(wt in WorkingTime, where: wt.user_id == ^user.id)
      |> Repo.delete_all()

      # Delete all clocks for this user
      from(c in Clock, where: c.user_id == ^user.id)
      |> Repo.delete_all()

      # Delete all team memberships for this user
      from(tm in TeamMembership, where: tm.user_id == ^user.id)
      |> Repo.delete_all()

      # Update tasks assigned to this user to be unassigned
      from(t in AsBackendTheme2.TaskManagement.Task, where: t.assigned_to_id == ^user.id)
      |> Repo.update_all(set: [assigned_to_id: nil])

      # Update tasks assigned by this user to be unassigned
      from(t in AsBackendTheme2.TaskManagement.Task, where: t.assigned_by_id == ^user.id)
      |> Repo.update_all(set: [assigned_by_id: nil])

      # If this user was a manager, remove them from teams they managed
      from(t in AsBackendTheme2.Team, where: t.manager_id == ^user.id)
      |> Repo.update_all(set: [manager_id: nil])

      # Now delete the user
      case Repo.delete(user) do
        {:ok, user} -> user
        {:error, changeset} -> Repo.rollback(changeset)
      end
    end)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  # Role Management

  # Role Management
  # Admin check
  def is_admin?(%User{role: %{name: "admin"}}), do: true
  def is_admin?(_), do: false

  def get_user(id) do
    case Repo.get(User, id) |> Repo.preload(:role) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end

  # Manager or admin check
  def is_manager_or_admin?(%User{role: %{name: name}}) when name in ["admin", "manager"], do: true
  def is_manager_or_admin?(_), do: false

  def update_user_role(%User{} = user, role_name) do
    case Repo.get_by(AsBackendTheme2.Accounts.Role, name: role_name) do
      nil ->
        {:error, :invalid_role}

      role ->
        user
        |> Ecto.Changeset.change(%{role_id: role.id})
        |> Repo.update()
    end
  end

  def add_user_to_team(current_user, target_user_id, team_id) do
    if is_manager_or_admin?(current_user) do
      %TeamMembership{}
      |> TeamMembership.changeset(%{user_id: target_user_id, team_id: team_id})
      |> Repo.insert()
    else
      {:error, :unauthorized}
    end
  end

  def remove_user_from_team(current_user, target_user_id, team_id) do
    if is_manager_or_admin?(current_user) do
      from(tm in TeamMembership,
        where: tm.user_id == ^target_user_id and tm.team_id == ^team_id
      )
      |> Repo.delete_all()
    else
      {:error, :unauthorized}
    end
  end

  # Password change for current user
  def change_user_password(%User{} = user, old_password, new_password) when is_binary(old_password) and is_binary(new_password) do
    case Argon2.verify_pass(old_password, user.password_hash || "") do
      true ->
        user
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.put_change(:password, new_password)
        |> User.registration_changeset(%{})
        |> Repo.update()

      false ->
        {:error, :invalid_old_password}
    end
  end
end
