defmodule AsBackendTheme2Web.UserController do
  use AsBackendTheme2Web, :controller

  alias AsBackendTheme2.Accounts
  alias AsBackendTheme2.Accounts.User
  alias AsBackendTheme2.Repo

  action_fallback AsBackendTheme2Web.FallbackController

  def index(conn, params) do
    users =
      AsBackendTheme2.Accounts.list_users()
      |> Enum.filter(fn user ->
        email_ok =
          is_nil(params["email"]) or
            String.downcase(user.email) == String.downcase(params["email"])

        first_name_ok =
          is_nil(params["first_name"]) or
            String.downcase(user.first_name || "") == String.downcase(params["first_name"])

        last_name_ok =
          is_nil(params["last_name"]) or
            String.downcase(user.last_name || "") == String.downcase(params["last_name"])

        email_ok and first_name_ok and last_name_ok
      end)

    render(conn, :index, users: users)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        user = AsBackendTheme2.Repo.preload(user, :role)

        conn
        |> put_status(:created)
        |> render(:show, user: user)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(json: AsBackendTheme2Web.UserJSON)
        |> render(:error, changeset: changeset)
    end
  end

  @spec show(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, :show, user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)

    case Accounts.update_user(user, user_params) do
      {:ok, %User{} = user} ->
        render(conn, :show, user: user)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(json: AsBackendTheme2Web.UserJSON)
        |> render(:error, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)

    case Accounts.delete_user(user) do
      {:ok, %User{}} ->
        send_resp(conn, :no_content, "")

      {:error, %Ecto.Changeset{errors: errors}} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(json: AsBackendTheme2Web.UserJSON)
        |> render(:error, changeset: %Ecto.Changeset{errors: errors})
    end
  end

  def change_role(conn, %{"id" => user_id, "role" => role_name}) do
    current_user_id = conn.assigns.current_user_id
    current_user = Accounts.get_user!(current_user_id)

    with true <- Accounts.is_admin?(current_user),
         {:ok, user} <- Accounts.get_user(user_id),
         {:ok, updated_user} <- Accounts.update_user_role(user, role_name),
         updated_user = Repo.preload(updated_user, :role) do
      conn
      |> put_status(:ok)
      |> render(:show, user: updated_user)
    else
      false ->
        conn
        |> put_status(:forbidden)
        |> json(%{error: "Only admins can promote or demote users"})

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "User not found"})

      {:error, :invalid_role} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Invalid role"})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(json: AsBackendTheme2Web.UserJSON)
        |> render(:error, changeset: changeset)
    end
  end

  def change_password(conn, %{"old_password" => old_password, "new_password" => new_password}) do
    current_user_id = conn.assigns.current_user_id
    user = Accounts.get_user!(current_user_id)

    case Accounts.change_user_password(user, old_password, new_password) do
      {:ok, _updated_user} ->
        conn
        |> put_status(:ok)
        |> json(%{message: "Password updated successfully"})

      {:error, :invalid_old_password} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Old password is incorrect"})

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(json: AsBackendTheme2Web.UserJSON)
        |> render(:error, changeset: changeset)
    end
  end
end
