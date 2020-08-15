defmodule Webchat.Administration.Encryption do

  def hash(pass), do: Pbkdf2.hash_pwd_salt(pass)

  def verify_pass(given_pass, hashed_pass) do
    Pbkdf2.verify_pass(given_pass, hashed_pass)
    |> verify_pass()
  end

  defp verify_pass(false) do
    # Avoid timing attacks
    Pbkdf2.no_user_verify()
    false
  end
  defp verify_pass(t), do: t

end
