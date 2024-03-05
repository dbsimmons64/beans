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
    data = Enum.map(accounts, fn acc -> %{x: acc.name, y: acc.balance} end) |> dbg()

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

    category_avg = Transactions.avg_category()

    series =
      Enum.map(category_avg, fn {_, avg} -> Decimal.mult(avg, 100) |> Decimal.to_integer() end)
      |> dbg()

    labels = Enum.map(category_avg, fn {label, _} -> label end) |> dbg()

    transactions = Transactions.daily_spend()
    dbg(length(transactions))

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
