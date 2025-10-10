defmodule AsBackendTheme2Web.TaskJSON do
  alias AsBackendTheme2.TaskManagement.Task

  @doc """
  Renders a list of tasks.
  """
  def index(%{tasks: tasks}) do
    %{data: for(task <- tasks, do: data(task))}
  end

  @doc """
  Renders a single task.
  """
  def show(%{task: task}) do
    %{data: data(task)}
  end

  defp data(%Task{} = task) do
    %{
      id: task.id,
      title: task.title,
      description: task.description,
      status: task.status,
      priority: task.priority,
      due_date: task.due_date,
      assigned_to_id: task.assigned_to_id,
      assigned_by_id: task.assigned_by_id,
      team_id: task.team_id,
      created_at: task.inserted_at,
      updated_at: task.updated_at,
      assigned_to: if(task.assigned_to, do: %{
        id: task.assigned_to.id,
        first_name: task.assigned_to.first_name,
        last_name: task.assigned_to.last_name,
        email: task.assigned_to.email
      }, else: nil),
      assigned_by: if(task.assigned_by, do: %{
        id: task.assigned_by.id,
        first_name: task.assigned_by.first_name,
        last_name: task.assigned_by.last_name,
        email: task.assigned_by.email
      }, else: nil),
      team: if(task.team, do: %{
        id: task.team.id,
        name: task.team.name
      }, else: nil)
    }
  end
end
