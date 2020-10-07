defmodule MyApp.Repo.Migrations.CreateUsersTable do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string, null: false
      add :email, :string, null: false

      add :org_id, references(:orgs), null: true
    end

    create unique_index(:users, :email)
  end
end
