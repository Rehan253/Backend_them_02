defmodule AsBackendTheme2Web.UserController do
  use AsBackendTheme2Web, :controller

  alias AsBackendTheme2.Accounts
  alias AsBackendTheme2.Accounts.User

  action_fallback AsBackendTheme2Web.FallbackController

  def index(conn, params) do
    users =
      AsBackendTheme2.Accounts.list_users()
      |> Enum.filter(fn user ->
        email_ok = is_nil(params["email"]) or String.downcase(user.email) == String.downcase(params["email"])
        username_ok = is_nil(params["username"]) or String.downcase(user.username) == String.downcase(params["username"])
        email_ok and username_ok
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
        |> put_status(:bad_request)
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

    with {:ok, %User{} = user} <- Accounts.update_user(user, user_params) do
      render(conn, :show, user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)

    with {:ok, %User{}} <- Accounts.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end
end
