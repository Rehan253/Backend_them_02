defmodule AsBackendTheme2.TimeTrackingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `AsBackendTheme2.TimeTracking` context.
  """

  @doc """
  Generate a working_time.
  """
  def working_time_fixture(attrs \\ %{}) do
    user = AsBackendTheme2.AccountsFixtures.user_fixture()

    {:ok, working_time} =
      attrs
      |> Enum.into(%{
        end: ~N[2025-09-23 12:26:00],
        start: ~N[2025-09-23 12:26:00],
        user_id: user.id
      })
      |> AsBackendTheme2.TimeTracking.create_working_time()

    working_time
  end

  @doc """
  Generate a clock.
  """
  def clock_fixture(attrs \\ %{}) do
    user = AsBackendTheme2.AccountsFixtures.user_fixture()

    {:ok, clock} =
      attrs
      |> Enum.into(%{
        status: true,
        time: ~N[2025-09-23 12:44:00],
        user_id: user.id
      })
      |> AsBackendTheme2.TimeTracking.create_clock()

    clock
  end
end
