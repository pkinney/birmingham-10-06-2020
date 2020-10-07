defmodule MyApp.Accounts do
  alias MyApp.Accounts.{Org, User}

  def change_org(%Org{} = org, attrs \\ %{}) do
    Org.changeset(org, attrs)
  end

  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  def create_org_with_admin(org_params, user_params) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:org, change_org(%Org{}, org_params))
    |> Ecto.Multi.insert(:user, fn %{org: org} ->
      Ecto.build_assoc(org, :users) |> change_user(user_params)
    end)
    |> MyApp.Repo.transaction()
  end
end
