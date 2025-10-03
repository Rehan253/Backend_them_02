defmodule AsBackendTheme2.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias AsBackendTheme2.Repo

  alias AsBackendTheme2.Accounts.User
  alias AsBackendTheme2.TimeTracking.WorkingTime
  alias AsBackendTheme2.TimeTracking.Clock

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Gets a single user by email.

  Returns `nil` if the User does not exist.

  ## Examples

      iex> get_user_by_email("user@example.com")
      %User{}

      iex> get_user_by_email("nonexistent@example.com")
      nil

  """
  def get_user_by_email(email) do
    Repo.get_by(User, email: email)
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs) do
    email = Map.get(attrs, "email")

    cond do
      is_nil(email) ->
        %User{}
        |> User.registration_changeset(attrs)
        |> Repo.insert()

      get_user_by_email(email) ->
        {:error, %Ecto.Changeset{} |> Ecto.Changeset.add_error(:email, "has already been taken")}

      true ->
        %User{}
        |> User.registration_changeset(attrs)
        |> Repo.insert()
    end
  end


  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.transaction(fn ->
      # Delete all working times for this user
      from(wt in WorkingTime, where: wt.user_id == ^user.id)
      |> Repo.delete_all()

      # Delete all clocks for this user
      from(c in Clock, where: c.user_id == ^user.id)
      |> Repo.delete_all()

      # Now delete the user
      case Repo.delete(user) do
        {:ok, user} -> user
        {:error, changeset} -> Repo.rollback(changeset)
      end
    end)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end
end
