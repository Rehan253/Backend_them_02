defmodule AsBackendTheme2Web.ClockControllerTest do
  @moduledoc """
  Tests for ClockController API endpoints.

  Tests the clock in/out functionality:
  - GET /api/clocks/:userID - List clock entries for user
  - POST /api/clocks/:userID - Toggle clock in/out status
  """

  use AsBackendTheme2Web.ConnCase

  import AsBackendTheme2.AccountsFixtures

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index_by_user/2" do
    test "lists all clocks for a user", %{conn: conn} do
      user = user_fixture()
      conn = get(conn, ~p"/api/clocks/#{user.id}")
      assert json_response(conn, 200)["data"] == []
    end

    test "returns empty list for invalid user ID", %{conn: conn} do
      conn = get(conn, ~p"/api/clocks/invalid")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "toggle/2" do
    test "clocks in user when no previous entries exist", %{conn: conn} do
      user = user_fixture()
      conn = post(conn, ~p"/api/clocks/#{user.id}")

      assert %{"id" => _id, "status" => true, "user_id" => user_id} =
               json_response(conn, 201)["data"]

      assert user_id == user.id
    end

    test "clocks out user when previously clocked in", %{conn: conn} do
      user = user_fixture()

      # First clock in
      conn = post(conn, ~p"/api/clocks/#{user.id}")
      assert %{"status" => true} = json_response(conn, 201)["data"]

      # Then clock out
      conn = post(conn, ~p"/api/clocks/#{user.id}")

      assert %{"id" => _id, "status" => false, "user_id" => user_id} =
               json_response(conn, 201)["data"]

      assert user_id == user.id
    end

    test "clocks in user when previously clocked out", %{conn: conn} do
      user = user_fixture()

      # Verify initial state - no clock entries
      conn = get(conn, ~p"/api/clocks/#{user.id}")
      initial_clocks = json_response(conn, 200)["data"]
      assert initial_clocks == []

      # Clock in
      conn = post(conn, ~p"/api/clocks/#{user.id}")
      clock_in_response = json_response(conn, 201)["data"]
      assert clock_in_response["status"] == true

      # Small delay to ensure different timestamps
      Process.sleep(10)

      # Clock out
      conn = post(conn, ~p"/api/clocks/#{user.id}")
      clock_out_response = json_response(conn, 201)["data"]
      assert clock_out_response["status"] == false

      # Verify the user is now clocked out by checking the clock out response
      # The clock out response should have status: false
      assert clock_out_response["status"] == false

      # Verify we have 2 clock entries total
      conn = get(conn, ~p"/api/clocks/#{user.id}")
      clocks = json_response(conn, 200)["data"]
      assert length(clocks) == 2

      # Find the clock out entry (should be the one with status: false)
      clock_out_entry = Enum.find(clocks, fn clock -> clock["status"] == false end)
      assert clock_out_entry != nil
      assert clock_out_entry["id"] == clock_out_response["id"]

      # Clock in again
      conn = post(conn, ~p"/api/clocks/#{user.id}")
      clock_in_again_response = json_response(conn, 201)["data"]
      assert clock_in_again_response["status"] == true
      assert clock_in_again_response["user_id"] == user.id
    end

    test "returns error for non-existent user", %{conn: conn} do
      conn = post(conn, ~p"/api/clocks/99999")
      assert %{"error" => "User not found"} = json_response(conn, 400)
    end

    test "returns error for invalid user ID", %{conn: conn} do
      conn = post(conn, ~p"/api/clocks/invalid")
      assert %{"error" => "Invalid user ID"} = json_response(conn, 400)
    end
  end

  describe "clock in/out flow integration" do
    test "complete clock in/out cycle creates working time entry", %{conn: conn} do
      user = user_fixture()

      # Clock in
      conn = post(conn, ~p"/api/clocks/#{user.id}")
      clock_in_response = json_response(conn, 201)["data"]
      assert clock_in_response["status"] == true

      # Clock out
      conn = post(conn, ~p"/api/clocks/#{user.id}")
      clock_out_response = json_response(conn, 201)["data"]
      assert clock_out_response["status"] == false

      # Verify working time was created
      conn = get(conn, ~p"/api/workingtime/#{user.id}")
      working_times = json_response(conn, 200)["data"]
      assert length(working_times) == 1

      working_time = hd(working_times)
      assert working_time["user_id"] == user.id
      assert working_time["start"] == clock_in_response["time"]
      assert working_time["end"] == clock_out_response["time"]
    end
  end
end
