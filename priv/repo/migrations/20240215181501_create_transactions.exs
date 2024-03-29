defmodule Beans.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :name, :string
      add :date, :date
      add :amount, :decimal, precision: 20, scale: 2
      add :type, :integer

      add :account_id, references(:accounts)
      add :category_id, references(:categories)
      add :counter_txn_id, references(:transactions, on_delete: :delete_all)
      timestamps()
    end
  end
end
