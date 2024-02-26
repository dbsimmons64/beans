defmodule Beans.Transactions.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  schema "transactions" do
    field(:name, :string)
    field(:date, :date)
    field(:amount, :decimal)
    field :type, Ecto.Enum, values: [standard: 1, split: 2, transfer: 3], default: :standard

    belongs_to(:account, Beans.Accounts.Account)
    belongs_to(:category, Beans.Categories.Category)
    has_many(:splits, Beans.Splits.Split, on_delete: :delete_all, on_replace: :delete)

    timestamps()
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:name, :date, :amount, :account_id, :category_id, :type])
    |> validate_required([:name, :date, :amount, :account_id, :type])
    |> possibly_save_splits()
    |> cast_assoc(:splits,
      with: &Beans.Splits.Split.changeset/2,
      sort_param: :notifications_order,
      drop_param: :notifications_delete
    )
    |> validate_total()
  end

  defp possibly_save_splits(changeset) do
    type = fetch_field!(changeset, :type)

    if type == :split do
      Ecto.Changeset.change(changeset, %{splits: []})
    else
      changeset
    end
  end

  defp validate_total(changeset) do
    # Only do this check if the changeset is valid

    splits = fetch_field!(changeset, :splits)
    transaction_amount = fetch_field!(changeset, :amount)

    if changeset.valid? && splits != [] do
      total_splits =
        Enum.map(splits, fn split -> split.amount || 0 end)
        |> Enum.reduce(fn amount, acc -> Decimal.add(amount, acc) end)

      if Decimal.compare(transaction_amount, total_splits) == :eq do
        changeset
      else
        add_error(changeset, :amount, "Splits must equal Amounts")
      end
    else
      changeset
    end
  end
end
