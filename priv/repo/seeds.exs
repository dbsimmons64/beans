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
alias Beans.Users.User

categories =
  Enum.map(["Food", "Drink", "Rent", "Clothes"], fn name ->
    {:ok, category} = Beans.Repo.insert(%Category{name: name})
    category.id
  end)

{:ok, account} = Beans.Repo.insert(%Account{name: "Current", balance: Decimal.new("1000.00")})

date = Date.add(Date.utc_today(), -365)

Enum.map(1..700, fn i ->
  Beans.Repo.insert(%Transaction{
    name: "txn_#{i}",
    date: Date.add(date, i),
    amount: :rand.uniform(100),
    account_id: account.id,
    category_id: Enum.random(categories),
    type: :payment_out
  })
end)

Beans.Users.register_user(%{email: "dave@email.com", password: "davedavedave"})

budget = %{
  housing: [
    %{description: "Mortgage/Rent", amount: 1200},
    %{description: "Utilities", amount: 150},
    %{description: "Home Insurance", amount: 50}
  ],
  transportation: [
    %{description: "Car Loan Payment", amount: 250},
    %{description: "Petrol", amount: 100},
    %{description: "Car Insurance", amount: 80},
    %{description: "Car Maintenance", amount: 30}
  ],
  household_expenses: [
    %{description: "Groceries", amount: 500}
  ],
  health: [
    %{description: "Health Insurance Premium", amount: 300},
    %{description: "Doctor Visits and Prescriptions", amount: 150}
  ],
  education: [
    %{description: "Children's School Expenses", amount: 200}
  ],
  entertainment: [
    %{description: "Dining Out/Entertainment", amount: 200},
    %{description: "Streaming Services", amount: 20}
  ],
  savings: [
    %{description: "Emergency Fund", amount: 400},
    %{description: "Retirement Savings", amount: 300}
  ],
  miscellaneous: [
    %{description: "Clothing", amount: 150},
    %{description: "Personal Care", amount: 50}
  ]
}
