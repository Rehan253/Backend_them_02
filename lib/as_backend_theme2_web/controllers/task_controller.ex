defmodule AsBackendTheme2Web.TaskController do
  use AsBackendTheme2Web, :controller

  alias AsBackendTheme2.TaskManagement
  alias AsBackendTheme2.TaskManagement.Task

  action_fallback AsBackendTheme2Web.FallbackController

  def index(conn, _params) do
    tasks = TaskManagement.list_tasks()
    render(conn, :index, tasks: tasks)
  end

  def create(conn, %{"task" => task_params}) do
    with {:ok, %Task{} = task} <- TaskManagement.create_task(task_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/tasks/#{task}")
      |> render(:show, task: task)
    end
  end

  def show(conn, %{"id" => id}) do
    task = TaskManagement.get_task!(id)
    render(conn, :show, task: task)
  end

  def update(conn, %{"id" => id, "task" => task_params}) do
    task = TaskManagement.get_task!(id)

    with {:ok, %Task{} = task} <- TaskManagement.update_task(task, task_params) do
      render(conn, :show, task: task)
    end
  end

  def delete(conn, %{"id" => id}) do
    task = TaskManagement.get_task!(id)

    with {:ok, %Task{}} <- TaskManagement.delete_task(task) do
      send_resp(conn, :no_content, "")
    end
  end

  def get_tasks_by_user(conn, %{"user_id" => user_id}) do
    tasks = TaskManagement.get_tasks_by_user(user_id)
    render(conn, :index, tasks: tasks)
  end

  def get_tasks_assigned_by_user(conn, %{"user_id" => user_id}) do
    tasks = TaskManagement.get_tasks_assigned_by_user(user_id)
    render(conn, :index, tasks: tasks)
  end

  def get_tasks_by_team(conn, %{"team_id" => team_id}) do
    tasks = TaskManagement.get_tasks_by_team(team_id)
    render(conn, :index, tasks: tasks)
  end
end
