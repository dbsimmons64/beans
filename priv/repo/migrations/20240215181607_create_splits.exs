defmodule Beans.Repo.Migrations.CreateSplits do
  use Ecto.Migration

  def change do
    create table(:splits) do
      add :description, :text
      add :amount, :decimal, precision: 20, scale: 2

      add :transaction_id, references(:transactions), on_delete: :delete_all
      add :category_id, references(:categories)

      timestamps()
    end
  end
end
