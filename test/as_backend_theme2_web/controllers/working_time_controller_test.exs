defmodule AsBackendTheme2Web.WorkingTimeControllerTest do
  use AsBackendTheme2Web.ConnCase

  import AsBackendTheme2.TimeTrackingFixtures
  import AsBackendTheme2.AccountsFixtures
  alias AsBackendTheme2.TimeTracking.WorkingTime

  @create_attrs %{
    working_time: %{
      start: ~N[2025-09-23 12:26:00],
      end: ~N[2025-09-23 12:26:00]
    }
  }
  @update_attrs %{
    working_time: %{
      start: ~N[2025-09-24 12:26:00],
      end: ~N[2025-09-24 12:26:00]
    }
  }
  @invalid_attrs %{working_time: %{start: nil, end: nil}}

  setup %{conn: conn} do
    user = user_fixture()
    {:ok, conn: put_req_header(conn, "accept", "application/json"), user: user}
  end

  describe "index_by_user" do
    test "lists working_times for user", %{conn: conn, user: user} do
      conn = get(conn, ~p"/api/workingtime/#{user.id}")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create_for_user" do
    test "renders working_time when data is valid", %{conn: conn, user: user} do
      conn = post(conn, ~p"/api/workingtime/#{user.id}", @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/workingtime/#{user.id}/#{id}")

      assert %{
               "id" => ^id,
               "end" => "2025-09-23T12:26:00",
               "start" => "2025-09-23T12:26:00"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = post(conn, ~p"/api/workingtime/#{user.id}", @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update" do
    setup [:create_working_time]

    test "renders working_time when data is valid", %{
      conn: conn,
      working_time: %WorkingTime{id: id} = working_time
    } do
      conn = put(conn, ~p"/api/workingtime/#{working_time.id}", @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/workingtime/#{working_time.user_id}/#{id}")

      assert %{
               "id" => ^id,
               "end" => "2025-09-24T12:26:00",
               "start" => "2025-09-24T12:26:00"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, working_time: working_time} do
      conn = put(conn, ~p"/api/workingtime/#{working_time.id}", @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete" do
    setup [:create_working_time]

    test "deletes chosen working_time", %{conn: conn, working_time: working_time} do
      conn = delete(conn, ~p"/api/workingtime/#{working_time.id}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/workingtime/#{working_time.user_id}/#{working_time.id}")
      end
    end
  end

  defp create_working_time(_) do
    working_time = working_time_fixture()

    %{working_time: working_time}
  end
end
