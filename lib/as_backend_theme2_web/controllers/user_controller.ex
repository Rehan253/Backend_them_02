defmodule AsBackendTheme2Web.UserController do
  use AsBackendTheme2Web, :controller

  alias AsBackendTheme2.Accounts
  alias AsBackendTheme2.Accounts.User

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
end
