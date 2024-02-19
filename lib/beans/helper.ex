defmodule Beans.Helpers do
  alias Beans.Repo

  @doc """
    A simple preload function to load associated attributes after an 
    INSERT or UPDATE as there is no way to do a preload as part of these 
    functions.
  """
  def preload({:ok, entity}, preloads) do
    {:ok, Repo.preload(entity, preloads)}
  end

  def preload({:error, error}, _preloads) do
    {:error, error}
  end
end
