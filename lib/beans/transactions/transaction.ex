defmodule Beans.Transactions.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  # txn types
  # payment_in
  # payment_out
  # trnsfer_in
  # transfer_out
  # split  - only payment out can have splits 
  @derive {
    Flop.Schema,
    filterable: [:type, :category_id],
    sortable: [:date],
    default_limit: 5,
    max_limit: 500,
    default_order: %{
      order_by: [:date],
      order_directions: [:asc]
    }
  }
  # transfer money from -> to 
  # user can only create a transfer out.
  # you cannot edit a transfer_in, only the original transfer_out 
  # A transfer in therefore belongs_to a transfer out.
  schema "transactions" do
    field(:name, :string)
    field(:date, :date)
    field(:amount, :decimal)

    field :type, Ecto.Enum,
      values: [payment_out: 1, payment_in: 2, transfer_out: 3, transfer_in: 4, split: 5],
      default: :payment_out

    belongs_to(:account, Beans.Accounts.Account)
    belongs_to(:category, Beans.Categories.Category)
    belongs_to(:counter_txn, Beans.Transactions.Transaction)
    has_many(:splits, Beans.Splits.Split, on_delete: :delete_all, on_replace: :delete)

    timestamps()
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [
      :name,
      :date,
      :amount,
      :account_id,
      :category_id,
      :type,
      :counter_txn_id
    ])
    |> validate_required([:name, :date, :amount, :account_id, :type])
    |> validate_type()
  end

  defp validate_type(changeset) do
    # Validate the transaction type
    type = fetch_field!(changeset, :type)

    validate_type(type, changeset)
  end

  defp validate_type(:split, changeset) do
    # possibly save split - not sure why we do this
    changeset
    |> cast_assoc(:splits,
      with: &Beans.Splits.Split.changeset/2,
      sort_param: :notifications_order,
      drop_param: :notifications_delete
    )
    |> validate_total()
  end

  defp validate_type(_type, changeset) do
    changeset
    |> Ecto.Changeset.change(%{splits: []})
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
