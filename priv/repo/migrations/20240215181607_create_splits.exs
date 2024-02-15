defmodule Beans.Repo.Migrations.CreateSplits do
  use Ecto.Migration

  def change do
    create table(:splits) do
      add :description, :text
      add :amount, :decimal

      add :transaction_id, references(:transactions)
      add :category_id, references(:categories)

      timestamps()
    end
  end
end
