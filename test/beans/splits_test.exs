defmodule Beans.SplitsTest do
  use Beans.DataCase

  alias Beans.Splits

  describe "splits" do
    alias Beans.Splits.Split

    import Beans.SplitsFixtures

    @invalid_attrs %{description: nil, amount: nil}

    test "list_splits/0 returns all splits" do
      split = split_fixture()
      assert Splits.list_splits() == [split]
    end

    test "get_split!/1 returns the split with given id" do
      split = split_fixture()
      assert Splits.get_split!(split.id) == split
    end

    test "create_split/1 with valid data creates a split" do
      valid_attrs = %{description: "some description", amount: "120.5"}

      assert {:ok, %Split{} = split} = Splits.create_split(valid_attrs)
      assert split.description == "some description"
      assert split.amount == Decimal.new("120.5")
    end

    test "create_split/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Splits.create_split(@invalid_attrs)
    end

    test "update_split/2 with valid data updates the split" do
      split = split_fixture()
      update_attrs = %{description: "some updated description", amount: "456.7"}

      assert {:ok, %Split{} = split} = Splits.update_split(split, update_attrs)
      assert split.description == "some updated description"
      assert split.amount == Decimal.new("456.7")
    end

    test "update_split/2 with invalid data returns error changeset" do
      split = split_fixture()
      assert {:error, %Ecto.Changeset{}} = Splits.update_split(split, @invalid_attrs)
      assert split == Splits.get_split!(split.id)
    end

    test "delete_split/1 deletes the split" do
      split = split_fixture()
      assert {:ok, %Split{}} = Splits.delete_split(split)
      assert_raise Ecto.NoResultsError, fn -> Splits.get_split!(split.id) end
    end

    test "change_split/1 returns a split changeset" do
      split = split_fixture()
      assert %Ecto.Changeset{} = Splits.change_split(split)
    end
  end
end
