defmodule BeansWeb.SplitLive.FormComponent do
  use BeansWeb, :live_component

  alias Beans.Splits

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage split records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="split-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:description]} type="text" label="Description" />
        <.input field={@form[:amount]} type="number" label="Amount" step="any" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Split</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{split: split} = assigns, socket) do
    changeset = Splits.change_split(split)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"split" => split_params}, socket) do
    changeset =
      socket.assigns.split
      |> Splits.change_split(split_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"split" => split_params}, socket) do
    save_split(socket, socket.assigns.action, split_params)
  end

  defp save_split(socket, :edit, split_params) do
    case Splits.update_split(socket.assigns.split, split_params) do
      {:ok, split} ->
        notify_parent({:saved, split})

        {:noreply,
         socket
         |> put_flash(:info, "Split updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_split(socket, :new, split_params) do
    case Splits.create_split(split_params) do
      {:ok, split} ->
        notify_parent({:saved, split})

        {:noreply,
         socket
         |> put_flash(:info, "Split created successfully")
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
