defmodule Beans.SplitsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Beans.Splits` context.
  """

  @doc """
  Generate a split.
  """
  def split_fixture(attrs \\ %{}) do
    {:ok, split} =
      attrs
      |> Enum.into(%{
        amount: "120.5",
        description: "some description"
      })
      |> Beans.Splits.create_split()

    split
  end
end
