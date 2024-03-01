defmodule BeansWeb.TransactionLive.Index do
  use BeansWeb, :live_view

  alias Beans.Accounts
  alias Beans.Transactions
  alias Beans.Transactions.Transaction

  @impl true
  def mount(%{"account_id" => account_id} = _params, _session, socket) do
    {:ok, stream(socket, :transactions, Transactions.list_transactions(account_id))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    socket = apply_action(socket, socket.assigns.live_action, params)

    case Transactions.list_txn(params) do
      {:ok, {txns, meta}} ->
        {:noreply, assign(socket, %{txns: txns, meta: meta})}

      {:error, _meta} ->
        # This will reset invalid parameters. Alternatively, you can assign
        # only the meta and render the errors, or you can ignore the error
        # case entirely.
        {:noreply, push_navigate(socket, to: ~p"/transactions")}
    end
  end

  defp apply_action(socket, :edit, %{"id" => id, "account_id" => account_id}) do
    socket
    |> assign(:page_title, "Edit Transaction")
    |> assign(:account, Accounts.get_account!(account_id))
    |> assign(:transaction, Transactions.get_transaction!(id))
  end

  defp apply_action(socket, :new, %{"account_id" => account_id}) do
    socket
    |> assign(:page_title, "New Transaction")
    |> assign(:account, Accounts.get_account!(account_id))
    |> assign(:transaction, %Transaction{})
  end

  defp apply_action(socket, :index, %{"account_id" => account_id} = _params) do
    socket
    |> assign(:page_title, "Listing Transactions")
    |> assign(:account, Accounts.get_account!(account_id))
    |> assign(:transaction, nil)
  end

  @impl true
  def handle_info({BeansWeb.TransactionLive.FormComponent, {:saved, transaction}}, socket) do
    {:noreply, stream_insert(socket, :transactions, transaction)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    transaction = Transactions.get_transaction!(id)

    {:ok, _} = Transactions.delete_transaction(transaction.type, transaction)

    socket = assign(socket, :account, Accounts.get_account!(transaction.account_id))
    {:noreply, stream_delete(socket, :transactions, transaction)}
  end
end
