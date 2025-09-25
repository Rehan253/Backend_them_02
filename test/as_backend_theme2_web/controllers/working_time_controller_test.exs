defmodule AsBackendTheme2Web.WorkingTimeControllerTest do
  use AsBackendTheme2Web.ConnCase

  import AsBackendTheme2.TimeTrackingFixtures
  alias AsBackendTheme2.TimeTracking.WorkingTime

  @create_attrs %{
    start: ~N[2025-09-23 12:26:00],
    end: ~N[2025-09-23 12:26:00]
  }
  @update_attrs %{
    start: ~N[2025-09-24 12:26:00],
    end: ~N[2025-09-24 12:26:00]
  }
  @invalid_attrs %{start: nil, end: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all working_times", %{conn: conn} do
      conn = get(conn, ~p"/api/working_times")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create working_time" do
    test "renders working_time when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/working_times", working_time: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/working_times/#{id}")

      assert %{
               "id" => ^id,
               "end" => "2025-09-23T12:26:00",
               "start" => "2025-09-23T12:26:00"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/working_times", working_time: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update working_time" do
    setup [:create_working_time]

    test "renders working_time when data is valid", %{conn: conn, working_time: %WorkingTime{id: id} = working_time} do
      conn = put(conn, ~p"/api/working_times/#{working_time}", working_time: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/working_times/#{id}")

      assert %{
               "id" => ^id,
               "end" => "2025-09-24T12:26:00",
               "start" => "2025-09-24T12:26:00"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, working_time: working_time} do
      conn = put(conn, ~p"/api/working_times/#{working_time}", working_time: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete working_time" do
    setup [:create_working_time]

    test "deletes chosen working_time", %{conn: conn, working_time: working_time} do
      conn = delete(conn, ~p"/api/working_times/#{working_time}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/working_times/#{working_time}")
      end
    end
  end

  defp create_working_time(_) do
    working_time = working_time_fixture()

    %{working_time: working_time}
  end
end
