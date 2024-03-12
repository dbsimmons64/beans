defmodule BeansWeb.OverviewLive.Index do
  use BeansWeb, :live_view

  alias Beans.Accounts
  alias Beans.Transactions
  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    accounts = Accounts.list_accounts()
    data = Enum.map(accounts, fn acc -> %{x: acc.name, y: acc.balance} end)

    option = %{
      chart: %{
        type: "bar"
      },
      series: [
        %{
          name: "Account",
          data: data
        }
      ]
    }

    total_per_category = Transactions.total_per_category()

    series =
      Enum.map(total_per_category, fn {_, avg} ->
        Decimal.mult(avg, 100) |> Decimal.to_integer()
      end)

    labels = Enum.map(total_per_category, fn {label, _} -> label end)

    transactions = Transactions.daily_spend()

    transaction_summary = get_last_n_transactions(10)

    {:noreply,
     socket
     |> assign(:option, option)
     |> assign(:labels, labels)
     |> assign(:transactions, transactions)
     |> assign(:transaction_summary, transaction_summary)
     |> assign(:series, series)}
  end

  defp get_last_n_transactions(number) do
    Transactions.last_n_transactions(number)
  end
end
