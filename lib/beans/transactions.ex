defmodule Beans.Transactions do
  @moduledoc """
  The Transactions context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Adapter.Transaction
  alias Ecto.Adapter.Transaction
  alias Ecto.Adapter.Transaction
  alias Ecto.Adapter.Transaction
  alias Ecto.Adapter.Transaction
  alias Beans.Accounts
  alias Beans.Categories.Category
  alias Beans.Transactions.Transaction
  alias Beans.Splits.Split
  alias Beans.Repo

  alias Beans.Transactions.Transaction

  @doc """
  Returns the list of transactions.

  ## Examples

      iex> list_transactions()
      [%Transaction{}, ...]

  """
  def list_transactions(account_id, params) do
    query =
      from t in Transaction,
        where: t.account_id == ^account_id,
        select: t,
        preload: [:category]

    Flop.validate_and_run(query, params, for: Transaction)
  end

  def last_n_transactions(number) do
    Repo.all(
      from t in Transaction,
        order_by: t.date,
        select: t,
        preload: [:category, :account],
        limit: ^number
    )
  end

  @doc """
  Gets a single transaction.

  Raises `Ecto.NoResultsError` if the Transaction does not exist.

  ## Examples

      iex> get_transaction!(123)
      %Transaction{}

      iex> get_transaction!(456)
      ** (Ecto.NoResultsError)

  """
  def get_transaction!(id),
    do: Repo.get!(Transaction, id) |> Repo.preload([:splits, :category])

  @doc """
  Create a transaction and update the associated account balance.
  """
  def create_transaction(type, attrs) when type in ["payment_out", "split"] do
    Beans.Helpers.transact(fn ->
      with {:ok, transaction} <- create_transaction(attrs),
           {:ok, _account} <- Accounts.decrease_balance(transaction) do
        {:ok, transaction}
      end
    end)
  end

  def create_transaction(type, attrs) when type in ["payment_in"] do
    Beans.Helpers.transact(fn ->
      with {:ok, transaction} <- create_transaction(attrs),
           {:ok, _account} <- Accounts.increase_balance(transaction) do
        {:ok, transaction}
      end
    end)
  end

  def create_transaction(type, attrs) when type in ["transfer_out"] do
    Beans.Helpers.transact(fn ->
      with {:ok, transaction} <- create_transaction(attrs),
           {:ok, _account} <- Accounts.decrease_balance(transaction),
           counter_attrs = create_counter_txn(transaction, attrs, :transfer_in),
           {:ok, counter_txn} <- create_transaction(counter_attrs),
           {:ok, _account} <- Accounts.increase_balance(counter_txn),
           {:ok, transaction} <-
             update_transaction(transaction, %{counter_txn_id: counter_txn.id}) do
        {:ok, transaction}
      end
    end)
  end

  def create_transaction(type, attrs) when type in ["transfer_in"] do
    Beans.Helpers.transact(fn ->
      with {:ok, transaction} <- create_transaction(attrs),
           {:ok, _account} <- Accounts.increase_balance(transaction),
           counter_attrs = create_counter_txn(transaction, attrs, :transfer_out),
           {:ok, counter_txn} <- create_transaction(counter_attrs),
           {:ok, _account} <- Accounts.decrease_balance(counter_txn),
           {:ok, transaction} <-
             update_transaction(transaction, %{counter_txn_id: counter_txn.id}) do
        {:ok, transaction}
      end
    end)
  end

  def create_counter_txn(transaction, attrs, type) do
    txn = Map.from_struct(transaction)

    %{
      txn
      | id: nil,
        type: type,
        counter_txn_id: transaction.id,
        account_id: attrs["to_account_id"]
    }
  end

  @doc """
  Creates a transaction.

  ## Examples

      iex> create_transaction(%{field: value})
      {:ok, %Transaction{}}

      iex> create_transaction(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_transaction(attrs \\ %{}) do
    %Transaction{}
    |> Transaction.changeset(attrs)
    |> Repo.insert()
    |> Beans.Helpers.preload([:splits, :category, :counter_txn])
  end

  @doc """
  Updates a transaction.

  ## Examples

      iex> update_transaction(transaction, %{field: new_value})
      {:ok, %Transaction{}}

      iex> update_transaction(transaction, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_transaction(%Transaction{} = transaction, attrs) do
    transaction
    |> Transaction.changeset(attrs)
    |> Repo.update()
    |> Beans.Helpers.preload(:category)
  end

  def delete_transaction(type, %Transaction{} = transaction)
      when type in [:payment_out, :split] do
    Beans.Helpers.transact(fn ->
      with {:ok, transaction} <- delete_transaction(transaction),
           {:ok, _account} <- Accounts.increase_balance(transaction) do
        {:ok, transaction}
      end
    end)
  end

  def delete_transaction(type, %Transaction{} = transaction) when type in [:payment_in] do
    Beans.Helpers.transact(fn ->
      with {:ok, transaction} <- delete_transaction(transaction),
           {:ok, _account} <- Accounts.decrease_balance(transaction) do
        {:ok, transaction}
      end
    end)
  end

  def delete_transaction(type, %Transaction{} = transaction) when type in [:transfer_in] do
    Beans.Helpers.transact(fn ->
      with {:ok, _account} <- Accounts.decrease_balance(transaction),
           counter_txn = get_transaction!(transaction.counter_txn_id),
           {:ok, _account} <- Accounts.increase_balance(counter_txn),
           {:ok, transaction} <- delete_transaction(transaction) do
        {:ok, transaction}
      end
    end)
  end

  def delete_transaction(type, %Transaction{} = transaction) when type in [:transfer_out] do
    Beans.Helpers.transact(fn ->
      with {:ok, _account} <- Accounts.increase_balance(transaction),
           counter_txn = get_transaction!(transaction.counter_txn_id),
           {:ok, _account} <- Accounts.decrease_balance(counter_txn),
           {:ok, transaction} <- delete_transaction(transaction) do
        {:ok, transaction}
      end
    end)
  end

  @doc """
  Deletes a transaction.

  ## Examples

      iex> delete_transaction(transaction)
      {:ok, %Transaction{}}

      iex> delete_transaction(transaction)
      {:error, %Ecto.Changeset{}}

  """
  def delete_transaction(%Transaction{} = transaction) do
    Repo.delete(transaction)
  end

  def total_per_category() do
    Map.merge(
      total_per_category(Transaction),
      total_per_category(Split),
      fn _cateogry, transaction_total, split_total ->
        Decimal.add(transaction_total, split_total)
      end
    )
  end

  def total_per_category(repo) do
    Repo.all(
      from(a in repo,
        join: c in Category,
        on: a.category_id == c.id,
        group_by: [a.category_id, c.name],
        select: {c.name, sum(a.amount)}
      )
    )
    |> Map.new()
  end

  def daily_spend() do
    today = Date.utc_today()
    thirty_days_ago = Date.add(today, -30)

    Repo.all(
      from(t in Transaction,
        select: %{x: t.date, y: sum(t.amount)},
        where: t.date > ^thirty_days_ago,
        where: t.date < ^today,
        group_by: t.date
      )
    )
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking transaction changes.

  ## Examples

      iex> change_transaction(transaction)
      %Ecto.Changeset{data: %Transaction{}}

  """
  def change_transaction(%Transaction{} = transaction, attrs \\ %{}) do
    Transaction.changeset(transaction, attrs)
  end
end
