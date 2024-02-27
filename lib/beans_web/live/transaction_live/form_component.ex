defmodule BeansWeb.TransactionLive.FormComponent do
  alias Beans.Accounts.Account
  use BeansWeb, :live_component

  alias Beans.Accounts
  alias Beans.Categories
  alias Beans.Transactions

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage transaction records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="transaction-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <div class="flex flex-row space-x-4 ">
          <.input
            field={@form[:type]}
            type="select"
            options={[{"Standard", :standard}, {"Split", :split}, {"Transfer", :transfer}]}
            label="Type"
            class="mx-4"
          />

          <.input field={@form[:name]} type="text" label="Name" />
          <.input field={@form[:date]} type="date" label="Date" />
          <.input field={@form[:amount]} type="number" label="Amount" step="any" />

          <.input
            :if={@type == :standard}
            field={@form[:category_id]}
            type="select"
            options={@categories}
            label="Category"
            class="mx-4"
          />

          <.input
            :if={@type == :transfer}
            field={@form[:foo]}
            type="select"
            options={@accounts}
            label="To Account"
            class="mx-4"
          />
        </div>

        <.input field={@form[:account_id]} type="hidden" value={@account.id} />

        <div :if={@type == :split}>
          <div class="divider divider-primary">Splits</div>
          <.inputs_for :let={f_nested} field={@form[:splits]}>
            <div class="flex space-x-4 mt-2">
              <input type="hidden" name="transaction[notifications_order][]" value={f_nested.index} />
              <.input type="text" field={f_nested[:description]} placeholder="description" />
              <.input type="number" field={f_nested[:amount]} placeholder="amount" step="any" />

              <.input field={f_nested[:category_id]} type="select" options={@categories} />
              <label>
                <input
                  type="checkbox"
                  name="transaction[notifications_delete][]"
                  value={f_nested.index}
                  class="hidden"
                />
                <.icon name="hero-x-mark" class="w-6 h-6 relative top-2" />
              </label>
            </div>
          </.inputs_for>

          <input type="hidden" name="transaction[notifications_delete][]" />

          <label class="block cursor-pointer mt-2">
            <input type="checkbox" name="transaction[notifications_order][]" class="hidden" />
            <.icon name="hero-plus-circle" /> add more
          </label>
        </div>
        <:actions>
          <.button phx-disable-with="Saving...">Save Transaction</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{transaction: transaction} = assigns, socket) do
    changeset = Transactions.change_transaction(transaction)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:categories, Categories.select_categories())
     |> assign(:accounts, Accounts.select_accounts())
     |> assign_form(changeset)
     |> assign(:type, Ecto.Changeset.get_field(changeset, :type))}
  end

  @impl true
  def handle_event("validate", %{"transaction" => transaction_params}, socket) do
    dbg(transaction_params)

    changeset =
      socket.assigns.transaction
      |> Transactions.change_transaction(transaction_params)
      |> Map.put(:action, :validate)

    socket =
      socket
      |> assign_form(changeset)
      |> assign(:type, Ecto.Changeset.get_field(changeset, :type))

    {:noreply, socket}
  end

  def handle_event("save", %{"transaction" => transaction_params}, socket) do
    save_transaction(socket, socket.assigns.action, transaction_params)
  end

  defp save_transaction(socket, :edit, transaction_params) do
    case Transactions.update_transaction(
           socket.assigns.transaction,
           socket.assigns.account,
           transaction_params
         ) do
      {:ok, transaction} ->
        notify_parent({:saved, transaction})

        {:noreply,
         socket
         |> put_flash(:info, "Transaction updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_transaction(socket, :new, transaction_params) do
    case Transactions.create_transaction(socket.assigns.account, transaction_params) do
      {:ok, transaction} ->
        notify_parent({:saved, transaction})

        {:noreply,
         socket
         |> put_flash(:info, "Transaction created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
