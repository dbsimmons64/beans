defmodule Beans.TransactionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Beans.Transactions` context.
  """

  @doc """
  Generate a transaction.
  """
  def transaction_fixture(attrs \\ %{}) do
    {:ok, transaction} =
      attrs
      |> Enum.into(%{
        amount: "120.5",
        date: ~D[2024-02-14],
        name: "some name"
      })
      |> Beans.Transactions.create_transaction()

    transaction
  end
end
