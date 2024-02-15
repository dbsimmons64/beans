defmodule BeansWeb.SplitLive.Index do
  use BeansWeb, :live_view

  alias Beans.Splits
  alias Beans.Splits.Split

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :splits, Splits.list_splits())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Split")
    |> assign(:split, Splits.get_split!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Split")
    |> assign(:split, %Split{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Splits")
    |> assign(:split, nil)
  end

  @impl true
  def handle_info({BeansWeb.SplitLive.FormComponent, {:saved, split}}, socket) do
    {:noreply, stream_insert(socket, :splits, split)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    split = Splits.get_split!(id)
    {:ok, _} = Splits.delete_split(split)

    {:noreply, stream_delete(socket, :splits, split)}
  end
end
