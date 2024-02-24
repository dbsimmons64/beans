defmodule Beans.Transactions do
  @moduledoc """
  The Transactions context.
  """

  import Ecto.Query, warn: false
  alias Beans.Accounts.Account
  alias Beans.Transactions.Transaction
  alias Beans.Repo

  alias Beans.Transactions.Transaction

  @doc """
  Returns the list of transactions.

  ## Examples

      iex> list_transactions()
      [%Transaction{}, ...]

  """
  def list_transactions(account_id) do
    query =
      from t in Transaction,
        where: t.account_id == ^account_id,
        select: t,
        preload: [:category]

    Repo.all(query)
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
  def create_transaction(account, attrs) do
    Beans.Helpers.transact(fn ->
      with {:ok, transaction} <- create_transaction(attrs),
           {:ok, _account} <-
             Beans.Accounts.update_balance(
               account,
               Decimal.mult(transaction.amount, Decimal.new(-1))
             ) do
        {:ok, transaction}
      end
    end)
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
    |> Beans.Helpers.preload([:splits, :category])
  end

  def update_transaction(%Transaction{} = transaction, %Account{} = account, attrs) do
    original_amount = transaction.amount
    Beans.Helpers.transact(fn ->
      with {:ok, transaction} <- update_transaction(transaction, attrs),
           {:ok, _account} <-
             Beans.Accounts.possibly_update_balance(
               account,
              original_amount,
            transaction.amount
             ) do
        {:ok, transaction}
      end
    end)
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

  def delete_transaction(%Transaction{} = transaction, %Account{} = account) do
    Beans.Helpers.transact(fn ->
      with {:ok, transaction} <- delete_transaction(transaction),
           {:ok, _account} <-
             Beans.Accounts.update_balance(
               account,
               transaction.amount
             ) do
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
