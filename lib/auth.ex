defmodule Auth do
  require GenServer
  require Logger
  def init([email, pass]) do
    {:ok, %{token: get_token_from_email(email, pass)}}
  end

  def start_link(email, pass) do
    GenServer.start_link(__MODULE__, [email,pass], name: __MODULE__)
  end

  def handle_call(:get_token, _from, token) do
    {:reply, token, token}
  end

  def get_public_key do
    resp = HTTPotion.get("localhost:3000/api/public_key")
    RSA.decode_key(resp.body)
  end

  def encrypt(email,pass) do
    blah = Poison.encode!(%{"email": email,"password": pass, "id": Nerves.Lib.UUID.generate,"version": 1})
    String.Chars.to_string(RSA.encrypt(blah, {:public, get_public_key}))
  end

  def get_token do
    GenServer.call(__MODULE__, :get_token)
  end

  defp get_token_from_email(email, pass) do
    enc = encrypt(email,pass)
    payload = Poison.encode!(%{user: %{credentials: :base64.encode_to_string(enc) |> String.Chars.to_string }} )
    resp = HTTPotion.post "localhost:3000/api/tokens", [body: payload, headers: ["Content-Type": "application/json"]]
    Map.get(Poison.decode!(resp.body), "token")
  end
end
