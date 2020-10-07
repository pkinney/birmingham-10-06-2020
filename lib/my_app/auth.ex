defmodule MyApp.Auth.Guardian do
  use Guardian, otp_app: :my_app

  def subject_for_token(email, _claims) do
    sub = email
    {:ok, sub}
  end

  def resource_from_claims(claims) do
    claims["sub"]
    |> case do
      nil -> {:error, :user_not_found}
      email -> {:ok, email}
    end
  end
end
