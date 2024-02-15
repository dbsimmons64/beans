defmodule Beans.Splits do
  @moduledoc """
  The Splits context.
  """

  import Ecto.Query, warn: false
  alias Beans.Repo

  alias Beans.Splits.Split

  @doc """
  Returns the list of splits.

  ## Examples

      iex> list_splits()
      [%Split{}, ...]

  """
  def list_splits do
    Repo.all(Split)
  end

  @doc """
  Gets a single split.

  Raises `Ecto.NoResultsError` if the Split does not exist.

  ## Examples

      iex> get_split!(123)
      %Split{}

      iex> get_split!(456)
      ** (Ecto.NoResultsError)

  """
  def get_split!(id), do: Repo.get!(Split, id)

  @doc """
  Creates a split.

  ## Examples

      iex> create_split(%{field: value})
      {:ok, %Split{}}

      iex> create_split(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_split(attrs \\ %{}) do
    %Split{}
    |> Split.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a split.

  ## Examples

      iex> update_split(split, %{field: new_value})
      {:ok, %Split{}}

      iex> update_split(split, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_split(%Split{} = split, attrs) do
    split
    |> Split.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a split.

  ## Examples

      iex> delete_split(split)
      {:ok, %Split{}}

      iex> delete_split(split)
      {:error, %Ecto.Changeset{}}

  """
  def delete_split(%Split{} = split) do
    Repo.delete(split)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking split changes.

  ## Examples

      iex> change_split(split)
      %Ecto.Changeset{data: %Split{}}

  """
  def change_split(%Split{} = split, attrs \\ %{}) do
    Split.changeset(split, attrs)
  end
end
