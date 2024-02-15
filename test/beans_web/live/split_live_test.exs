defmodule BeansWeb.SplitLiveTest do
  use BeansWeb.ConnCase

  import Phoenix.LiveViewTest
  import Beans.SplitsFixtures

  @create_attrs %{description: "some description", amount: "120.5"}
  @update_attrs %{description: "some updated description", amount: "456.7"}
  @invalid_attrs %{description: nil, amount: nil}

  defp create_split(_) do
    split = split_fixture()
    %{split: split}
  end

  describe "Index" do
    setup [:create_split]

    test "lists all splits", %{conn: conn, split: split} do
      {:ok, _index_live, html} = live(conn, ~p"/splits")

      assert html =~ "Listing Splits"
      assert html =~ split.description
    end

    test "saves new split", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/splits")

      assert index_live |> element("a", "New Split") |> render_click() =~
               "New Split"

      assert_patch(index_live, ~p"/splits/new")

      assert index_live
             |> form("#split-form", split: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#split-form", split: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/splits")

      html = render(index_live)
      assert html =~ "Split created successfully"
      assert html =~ "some description"
    end

    test "updates split in listing", %{conn: conn, split: split} do
      {:ok, index_live, _html} = live(conn, ~p"/splits")

      assert index_live |> element("#splits-#{split.id} a", "Edit") |> render_click() =~
               "Edit Split"

      assert_patch(index_live, ~p"/splits/#{split}/edit")

      assert index_live
             |> form("#split-form", split: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#split-form", split: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/splits")

      html = render(index_live)
      assert html =~ "Split updated successfully"
      assert html =~ "some updated description"
    end

    test "deletes split in listing", %{conn: conn, split: split} do
      {:ok, index_live, _html} = live(conn, ~p"/splits")

      assert index_live |> element("#splits-#{split.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#splits-#{split.id}")
    end
  end

  describe "Show" do
    setup [:create_split]

    test "displays split", %{conn: conn, split: split} do
      {:ok, _show_live, html} = live(conn, ~p"/splits/#{split}")

      assert html =~ "Show Split"
      assert html =~ split.description
    end

    test "updates split within modal", %{conn: conn, split: split} do
      {:ok, show_live, _html} = live(conn, ~p"/splits/#{split}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Split"

      assert_patch(show_live, ~p"/splits/#{split}/show/edit")

      assert show_live
             |> form("#split-form", split: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#split-form", split: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/splits/#{split}")

      html = render(show_live)
      assert html =~ "Split updated successfully"
      assert html =~ "some updated description"
    end
  end
end
