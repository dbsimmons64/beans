# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Beans.Repo.insert!(%Beans.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
#
alias Beans.Accounts.Account
alias Beans.Categories.Category
alias Beans.Transactions.Transaction

{:ok, category} = Beans.Repo.insert(%Category{name: "Food"}) |> dbg()

{:ok, account} = Beans.Repo.insert(%Account{name: "Current", balance: Decimal.new("1000.00")})

Enum.map(1..1000, fn i ->
  Beans.Repo.insert(%Transaction{
    name: "txn_",
    amount: :rand.uniform(100),
    account_id: account.id,
    category_id: category.id,
    type: :payment_out
  })
end)
