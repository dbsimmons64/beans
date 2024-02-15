defmodule Beans.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add :name, :text

      timestamps()
    end
  end
end
