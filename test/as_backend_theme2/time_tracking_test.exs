defmodule AsBackendTheme2.TimeTrackingTest do
  use AsBackendTheme2.DataCase

  alias AsBackendTheme2.TimeTracking

  describe "working_times" do
    alias AsBackendTheme2.TimeTracking.WorkingTime

    import AsBackendTheme2.TimeTrackingFixtures

    @invalid_attrs %{start: nil, end: nil}

    test "list_working_times/0 returns all working_times" do
      working_time = working_time_fixture()
      assert TimeTracking.list_working_times() == [working_time]
    end

    test "get_working_time!/1 returns the working_time with given id" do
      working_time = working_time_fixture()
      assert TimeTracking.get_working_time!(working_time.id) == working_time
    end

    test "create_working_time/1 with valid data creates a working_time" do
      valid_attrs = %{start: ~N[2025-09-23 12:26:00], end: ~N[2025-09-23 12:26:00]}

      assert {:ok, %WorkingTime{} = working_time} = TimeTracking.create_working_time(valid_attrs)
      assert working_time.start == ~N[2025-09-23 12:26:00]
      assert working_time.end == ~N[2025-09-23 12:26:00]
    end

    test "create_working_time/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = TimeTracking.create_working_time(@invalid_attrs)
    end

    test "update_working_time/2 with valid data updates the working_time" do
      working_time = working_time_fixture()
      update_attrs = %{start: ~N[2025-09-24 12:26:00], end: ~N[2025-09-24 12:26:00]}

      assert {:ok, %WorkingTime{} = working_time} = TimeTracking.update_working_time(working_time, update_attrs)
      assert working_time.start == ~N[2025-09-24 12:26:00]
      assert working_time.end == ~N[2025-09-24 12:26:00]
    end

    test "update_working_time/2 with invalid data returns error changeset" do
      working_time = working_time_fixture()
      assert {:error, %Ecto.Changeset{}} = TimeTracking.update_working_time(working_time, @invalid_attrs)
      assert working_time == TimeTracking.get_working_time!(working_time.id)
    end

    test "delete_working_time/1 deletes the working_time" do
      working_time = working_time_fixture()
      assert {:ok, %WorkingTime{}} = TimeTracking.delete_working_time(working_time)
      assert_raise Ecto.NoResultsError, fn -> TimeTracking.get_working_time!(working_time.id) end
    end

    test "change_working_time/1 returns a working_time changeset" do
      working_time = working_time_fixture()
      assert %Ecto.Changeset{} = TimeTracking.change_working_time(working_time)
    end
  end

  describe "clocks" do
    alias AsBackendTheme2.TimeTracking.Clock

    import AsBackendTheme2.TimeTrackingFixtures

    @invalid_attrs %{status: nil, time: nil}

    test "list_clocks/0 returns all clocks" do
      clock = clock_fixture()
      assert TimeTracking.list_clocks() == [clock]
    end

    test "get_clock!/1 returns the clock with given id" do
      clock = clock_fixture()
      assert TimeTracking.get_clock!(clock.id) == clock
    end

    test "create_clock/1 with valid data creates a clock" do
      valid_attrs = %{status: true, time: ~N[2025-09-23 12:44:00]}

      assert {:ok, %Clock{} = clock} = TimeTracking.create_clock(valid_attrs)
      assert clock.status == true
      assert clock.time == ~N[2025-09-23 12:44:00]
    end

    test "create_clock/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = TimeTracking.create_clock(@invalid_attrs)
    end

    test "update_clock/2 with valid data updates the clock" do
      clock = clock_fixture()
      update_attrs = %{status: false, time: ~N[2025-09-24 12:44:00]}

      assert {:ok, %Clock{} = clock} = TimeTracking.update_clock(clock, update_attrs)
      assert clock.status == false
      assert clock.time == ~N[2025-09-24 12:44:00]
    end

    test "update_clock/2 with invalid data returns error changeset" do
      clock = clock_fixture()
      assert {:error, %Ecto.Changeset{}} = TimeTracking.update_clock(clock, @invalid_attrs)
      assert clock == TimeTracking.get_clock!(clock.id)
    end

    test "delete_clock/1 deletes the clock" do
      clock = clock_fixture()
      assert {:ok, %Clock{}} = TimeTracking.delete_clock(clock)
      assert_raise Ecto.NoResultsError, fn -> TimeTracking.get_clock!(clock.id) end
    end

    test "change_clock/1 returns a clock changeset" do
      clock = clock_fixture()
      assert %Ecto.Changeset{} = TimeTracking.change_clock(clock)
    end
  end
end
