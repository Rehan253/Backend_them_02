defmodule AsBackendTheme2Web.Plugs.AuthPlug do
  import Plug.Conn
  alias AsBackendTheme2Web.Auth.JwtAuth

  def init(opts), do: opts

  def call(conn, _opts) do
    with {:ok, token} <- fetch_token(conn),
         {:ok, claims} <- JwtAuth.verify_token(token),
         true <- valid_csrf?(conn, claims),
         user when not is_nil(user) <- AsBackendTheme2.Accounts.get_user!(claims["sub"]) do
      conn
      |> assign(:current_user_id, claims["sub"])
      |> assign(:current_user, user)
    else
      _ ->
        conn
        |> send_resp(:unauthorized, "Unauthorized or CSRF check failed")
        |> halt()
    end
  end

  defp fetch_token(conn) do
    case fetch_cookies(conn) do
      %{cookies: %{"access_token" => token}} -> {:ok, token}
      _ -> {:error, :missing_token}
    end
  end

  defp valid_csrf?(%Plug.Conn{method: "GET"}, _claims), do: true

  defp valid_csrf?(%Plug.Conn{} = conn, claims) do
    csrf_from_header = get_req_header(conn, "x-csrf-token") |> List.first()
    csrf_from_token = Map.get(claims, "csrf")
    csrf_from_header == csrf_from_token
  end
end
