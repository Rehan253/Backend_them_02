defmodule AsBackendTheme2Web.WorkingTimeController do
  use AsBackendTheme2Web, :controller

  alias AsBackendTheme2.TimeTracking
  alias AsBackendTheme2.TimeTracking.WorkingTime

  # GET /api/workingtime/:userID?start=...&end=...
  def index_by_user(conn, %{"userID" => user_id} = params) do
    working_times =
      TimeTracking.list_working_times_by_user(user_id, params["start"], params["end"])

    json(conn, working_times)
  end

  # GET /api/workingtime/:userID/:id
  def show_one(conn, %{"userID" => user_id_str, "id" => id_str}) do
    case {Integer.parse(user_id_str), Integer.parse(id_str)} do
      {{user_id, ""}, {working_time_id, ""}} ->
        case TimeTracking.get_working_time_by_user(working_time_id, user_id) do
          nil ->
            conn
            |> put_status(:not_found)
            |> json(%{error: "Working time not found for this user"})

          working_time ->
            conn
            |> put_status(:ok)
            |> render(:show, working_time: working_time)
        end

      _ ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Invalid user ID or working time ID"})
    end
  end


  # POST /api/workingtime/:userID
  def create_for_user(conn, %{"userID" => user_id} = params) do
    attrs = Map.put(params["working_time"] || %{}, "user_id", user_id)

    case TimeTracking.create_working_time(attrs) do
      {:ok, working_time} ->
        conn
        |> put_status(:created)
        |> render(:show, working_time: working_time)

      {:error, changeset} ->
        conn
        |> put_status(:bad_request)
        |> put_view(json: AsBackendTheme2Web.WorkingTimeJSON) # 👈 this is what was missing
        |> render(:error, changeset: changeset)
    end
  end


  # PUT /api/workingtime/:id
  def update(conn, %{"id" => id, "working_time" => wt_params}) do
    case TimeTracking.get_working_time(id) do
      nil ->
        send_resp(conn, 404, "Not found")

      working_time ->
        case TimeTracking.update_working_time(working_time, wt_params) do
          {:ok, wt} -> json(conn, wt)
          {:error, changeset} ->
            conn
            |> put_status(:bad_request)
            |> json(%{error: "Update failed", details: changeset})
        end
    end
  end

  # DELETE /api/workingtime/:id
  def delete(conn, %{"id" => id}) do
    case TimeTracking.get_working_time(id) do
      nil -> send_resp(conn, 404, "Not found")
      wt ->
        {:ok, _} = TimeTracking.delete_working_time(wt)
        send_resp(conn, 204, "")
    end
  end
end
