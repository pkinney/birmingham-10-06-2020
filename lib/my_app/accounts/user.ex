defmodule MyApp.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :name, :string
    field :email, :string
    belongs_to :org, MyApp.Accounts.Org
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email])
    |> validate_required([:name, :email])
    |> validate_length(:name, min: 3)
    |> validate_format(
      :email,
      ~r/^\S+@\S+\.\S+$/,
      message: "must be a valid email"
    )
    |> unique_constraint(:email)
  end
end
