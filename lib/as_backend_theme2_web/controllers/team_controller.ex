defmodule AsBackendTheme2Web.TeamController do
  use AsBackendTheme2Web, :controller
  alias AsBackendTheme2.Team

  alias AsBackendTheme2.Accounts
  alias AsBackendTheme2.Repo

  def index(conn, _params) do
    teams = Repo.all(Team) |> Repo.preload(manager: :role, users: :role)
    conn |> json(%{data: teams})
  end

  def show(conn, %{"id" => id}) do
    case Repo.get(Team, id) |> Repo.preload(manager: :role, users: :role) do
      nil ->
        conn |> put_status(:not_found) |> json(%{error: "Team not found"})

      team ->
        conn |> json(%{data: team})
    end
  end

  def members(conn, %{"team_id" => team_id}) do
    case Repo.get(Team, team_id) |> Repo.preload(users: :role) do
      nil ->
        conn |> put_status(:not_found) |> json(%{error: "Team not found"})

      team ->
        conn |> json(%{data: team.users})
    end
  end

  def create(conn, %{"team" => team_params}) do
    case Repo.insert(Team.changeset(%Team{}, team_params)) do
      {:ok, team} ->
        conn
        |> put_status(:created)
        |> json(%{id: team.id, name: team.name, manager_id: team.manager_id})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{
          error: "Could not create team",
          details: Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)
        })
    end
  end

  def add_user(conn, %{"team_id" => team_id, "user_id" => user_id}) do
    with {:ok, current_user} <- Accounts.get_user(conn.assigns.current_user_id),
         {:ok, _target_user} <- Accounts.get_user(String.to_integer(user_id)) do
      case Accounts.add_user_to_team(
             current_user,
             String.to_integer(user_id),
             String.to_integer(team_id)
           ) do
        {:ok, _membership} ->
          send_resp(conn, :created, "User added to team")

        {:error, :unauthorized} ->
          conn
          |> put_status(:forbidden)
          |> json(%{error: "Not allowed"})

        {:error, %Ecto.Changeset{} = changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{
            error: "Could not add user",
            details: Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)
          })
      end
    else
      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "User not found"})
    end
  end

  def remove_user(conn, %{"team_id" => team_id, "user_id" => user_id}) do
    with {:ok, current_user} <- Accounts.get_user(conn.assigns.current_user_id) do
      case Accounts.remove_user_from_team(
             current_user,
             String.to_integer(user_id),
             String.to_integer(team_id)
           ) do
        {:error, :unauthorized} ->
          conn |> put_status(:forbidden) |> json(%{error: "Not allowed"})

        {_count, _} ->
          send_resp(conn, :no_content, "")
      end
    else
      {:error, :not_found} ->
        conn |> put_status(:not_found) |> json(%{error: "User not found"})
    end
  end
end
