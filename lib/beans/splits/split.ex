defmodule Beans.Splits.Split do
  use Ecto.Schema
  import Ecto.Changeset

  schema "splits" do
    field :description, :string
    field :amount, :decimal
    belongs_to :transaction, Beans.Transactions.Transaction
    belongs_to :category, Beans.Categories.Category

    timestamps()
  end

  @doc false
  def changeset(split, attrs) do
    split
    |> cast(attrs, [:description, :amount])
    |> validate_required([:description, :amount])
  end
end
