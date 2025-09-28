defmodule AsBackendTheme2.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `AsBackendTheme2.Accounts` context.
  """

  @doc """
  Generate a unique user email.
  """
  def unique_user_email, do: "user#{System.unique_integer([:positive])}@example.com"

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: unique_user_email(),
        first_name: "Test",
        last_name: "User"
      })
      |> AsBackendTheme2.Accounts.create_user()

    user
  end
end
