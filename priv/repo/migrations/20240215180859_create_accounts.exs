defmodule Beans.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      add :name, :text
      add :balance, :decimal

      timestamps()
    end
  end
end
