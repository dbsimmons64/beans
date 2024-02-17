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
    |> cast(attrs, [:name, :date, :amount, :account_id])
    |> validate_required([:name, :date, :amount, :account_id])
    |> cast_assoc(:splits,
      with: &splits_changeset/2,
      sort_param: :notifications_order,
      drop_param: :notifications_delete
    )
    |> validate_total()
  end

  defp splits_changeset(email, attrs) do
    email
    |> cast(attrs, [:description])
    |> validate_required([:description])
  end

  defp validate_total(changeset) do
    # Only do this check if the changeset is valid  
    dbg(changeset)
    splits = fetch_field!(changeset, :splits)

    for split <- splits do
      dbg(split.description)
    end

    #    Enum.map(splits, fn split -> split.amount end) |> dbg() |> Enum.sum() |> dbg()
    changeset
  end
end
