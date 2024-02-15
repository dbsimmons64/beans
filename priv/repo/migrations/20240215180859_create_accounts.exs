defmodule Beans.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      add :name, :text
      add :balance, :decimal, precision: 20, scale: 2

      timestamps()
    end
  end
end
