defmodule Beans.Transactions.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  schema "transactions" do
    field :name, :string
    field :date, :date
    field :amount, :decimal

    belongs_to :account, Beans.Accounts.Account
    belongs_to :category, Beans.Categories.Category
    has_many :splits, Beans.Splits.Split

    timestamps()
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:name, :date, :amount])
    |> validate_required([:name, :date, :amount])
  end
end
