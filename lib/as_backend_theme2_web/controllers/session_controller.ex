defmodule AsBackendTheme2Web.SessionController do
  use AsBackendTheme2Web, :controller

  alias AsBackendTheme2.Accounts
  alias AsBackendTheme2Web.Auth.JwtAuth

  def login(conn, %{"email" => email, "password" => password}) do
    case Accounts.get_user_by_email(email) do
      nil ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid credentials"})

      user ->
        if Argon2.verify_pass(password, user.password_hash) do
          {:ok, token, claims} = JwtAuth.generate_token(user)

          conn
          |> put_resp_cookie("access_token", token,
            http_only: true,
            secure: true,
            same_site: "Lax",
            # 1 hour
            max_age: 3600
          )
          |> json(%{
            message: "Login successful",
            token: token,
            csrf: claims["csrf"],
            user_id: user.id,
            role_id: user.role_id
          })
        else
          conn
          |> put_status(:unauthorized)
          |> json(%{error: "Invalid credentials"})
        end
    end
  end

  def logout(conn, _params) do
    conn
    |> put_resp_cookie("access_token", "",
      http_only: true,
      secure: true,
      same_site: "Lax",
      # Expire immediately
      max_age: 0
    )
    |> json(%{message: "Logout successful"})
  end
end
