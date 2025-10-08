defmodule AsBackendTheme2Web.ChangePasswordControllerTest do
  use AsBackendTheme2Web.ConnCase

  import AsBackendTheme2.AccountsFixtures
  alias AsBackendTheme2.{Repo}
  alias AsBackendTheme2.Accounts.User
  alias AsBackendTheme2Web.Auth.JwtAuth

  setup %{conn: conn} do
    conn = put_req_header(conn, "accept", "application/json")
    {:ok, conn: conn}
  end

  defp auth_conn(conn, user) do
    {:ok, token, claims} = JwtAuth.generate_token(user)

    conn
    |> Plug.Test.put_req_cookie("access_token", token)
    |> put_req_header("x-csrf-token", claims["csrf"])
  end

  describe "POST /api/users/change-password" do
    test "updates password when old_password is correct", %{conn: conn} do
      user = user_fixture(%{password: "oldpass123"})
      conn = auth_conn(conn, user)

      params = %{"old_password" => "oldpass123", "new_password" => "newpass456"}
      conn = post(conn, ~p"/api/users/change-password", params)

      assert %{"message" => "Password updated successfully"} = json_response(conn, 200)

      updated = Repo.get!(User, user.id)
      assert Argon2.verify_pass("newpass456", updated.password_hash)
    end

    test "returns 401 when old_password is incorrect", %{conn: conn} do
      user = user_fixture(%{password: "oldpass123"})
      conn = auth_conn(conn, user)

      params = %{"old_password" => "wrongpass", "new_password" => "newpass456"}
      conn = post(conn, ~p"/api/users/change-password", params)

      assert %{"error" => _} = json_response(conn, 401)
    end

    test "returns 422 for validation errors (new password too short)", %{conn: conn} do
      user = user_fixture(%{password: "oldpass123"})
      conn = auth_conn(conn, user)

      params = %{"old_password" => "oldpass123", "new_password" => "123"}
      conn = post(conn, ~p"/api/users/change-password", params)

      # structure comes from UserJSON error rendering; assert status only to avoid coupling
      assert json_response(conn, 422)
    end
  end
end


