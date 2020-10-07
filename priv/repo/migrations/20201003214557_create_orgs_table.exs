defmodule MyApp.Repo.Migrations.CreateOrgsTable do
  use Ecto.Migration

  def change do
    create table(:orgs) do
      add :name, :text, null: false
    end

    create unique_index(:orgs, :name)
  end
end
