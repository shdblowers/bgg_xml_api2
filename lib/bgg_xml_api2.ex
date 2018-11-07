defmodule BggXmlApi2 do
  @moduledoc """
  High level convenience functions.
  """

  alias BggXmlApi2.Item

  @doc """
  A convenience function for doing an exact match search on a board game and
  retrieving info on the top result returned.
  """
  @spec board_game_info(String.t()) :: {:ok, %Item{}} | {:error, :no_results}
  def board_game_info(name) do
    search_result = Item.search(name, exact: true, type: ["boardgame"])

    case search_result do
      {:ok, []} ->
        {:error, :no_results}

      {:ok, items} ->
        items
        |> Enum.max_by(fn i -> String.to_integer(i.year_published) end)
        |> Map.get(:id)
        |> Item.info()

      :error ->
        {:error, :no_results}
    end
  end

  def board_game_id(name) do
    search_result = Item.search(name, exact: true, type: ["boardgame"])

    case search_result do
      {:ok, []} ->
        {:error, :no_results}

      {:ok, items} ->
        id =
          items
          |> Enum.filter(fn i -> not is_nil(i.year_published) end)
          |> Enum.max_by(fn i -> String.to_integer(i.year_published) end)
          |> Map.get(:id)

        {:ok, id}

      :error ->
        {:error, :no_results}
    end
  end
end
