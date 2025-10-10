defmodule AsBackendTheme2.TaskManagement do
  @moduledoc """
  The TaskManagement context provides functions for managing tasks.
  """

  import Ecto.Query, warn: false
  alias AsBackendTheme2.Repo

  alias AsBackendTheme2.TaskManagement.Task

  @doc """
  Returns the list of tasks.

  ## Examples

      iex> list_tasks()
      [%Task{}, ...]

  """
  def list_tasks do
    Task
    |> preload([assigned_to: :role, assigned_by: :role, team: :manager])
    |> Repo.all()
  end

  @doc """
  Gets a single task.

  Raises `Ecto.NoResultsError` if the Task does not exist.

  ## Examples

      iex> get_task!(123)
      %Task{}

      iex> get_task!(456)
      ** (Ecto.NoResultsError)

  """
  def get_task!(id) do
    Task
    |> preload([assigned_to: :role, assigned_by: :role, team: :manager])
    |> Repo.get!(id)
  end

  @doc """
  Creates a task.

  ## Examples

      iex> create_task(%{field: value})
      {:ok, %Task{}}

      iex> create_task(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_task(attrs \\ %{}) do
    %Task{}
    |> Task.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, task} -> {:ok, Repo.preload(task, [assigned_to: :role, assigned_by: :role, team: :manager])}
      error -> error
    end
  end

  @doc """
  Updates a task.

  ## Examples

      iex> update_task(task, %{field: new_value})
      {:ok, %Task{}}

      iex> update_task(task, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_task(%Task{} = task, attrs) do
    task
    |> Task.changeset(attrs)
    |> Repo.update()
    |> case do
      {:ok, task} -> {:ok, Repo.preload(task, [assigned_to: :role, assigned_by: :role, team: :manager])}
      error -> error
    end
  end

  @doc """
  Deletes a task.

  ## Examples

      iex> delete_task(task)
      {:ok, %Task{}}

      iex> delete_task(task)
      {:error, %Ecto.Changeset{}}

  """
  def delete_task(%Task{} = task) do
    Repo.delete(task)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking task changes.

  ## Examples

      iex> change_task(task)
      %Ecto.Changeset{data: %Task{}}

  """
  def change_task(%Task{} = task, attrs \\ %{}) do
    Task.changeset(task, attrs)
  end

  @doc """
  Gets tasks assigned to a specific user.
  """
  def get_tasks_by_user(user_id) do
    Task
    |> preload([assigned_to: :role, assigned_by: :role, team: :manager])
    |> where([t], t.assigned_to_id == ^user_id)
    |> Repo.all()
  end

  @doc """
  Gets tasks assigned by a specific user.
  """
  def get_tasks_assigned_by_user(user_id) do
    Task
    |> preload([assigned_to: :role, assigned_by: :role, team: :manager])
    |> where([t], t.assigned_by_id == ^user_id)
    |> Repo.all()
  end

  @doc """
  Gets tasks for a specific team.
  """
  def get_tasks_by_team(team_id) do
    Task
    |> preload([assigned_to: :role, assigned_by: :role, team: :manager])
    |> where([t], t.team_id == ^team_id)
    |> Repo.all()
  end
end
