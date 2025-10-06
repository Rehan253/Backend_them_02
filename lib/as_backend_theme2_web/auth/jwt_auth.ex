defmodule AsBackendTheme2Web.Auth.JwtAuth do
  use Joken.Config

  @secret_key "super_secret_key_should_be_env_var"

  @impl true
  def token_config do
    default_claims(skip: [:aud, :iss, :jti, :nbf])
    |> add_claim("csrf", fn -> random_csrf() end, &is_binary/1)
  end

  def generate_token(user) do
    claims = %{"sub" => to_string(user.id)}
    signer = Joken.Signer.create("HS256", @secret_key)

    with {:ok, token, claims} <- generate_and_sign(claims, signer) do
      {:ok, token, claims}
    end
  end

  def verify_token(token) do
    signer = Joken.Signer.create("HS256", @secret_key)
    verify_and_validate(token, signer)
  end

  def get_csrf_from_token(token) do
    case verify_token(token) do
      {:ok, claims} -> Map.get(claims, "csrf")
      _ -> nil
    end
  end

  defp random_csrf do
    :crypto.strong_rand_bytes(16)
    |> Base.url_encode64(padding: false)
  end
end
