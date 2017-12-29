defmodule BggXmlApi2 do
  alias BggXmlApi2.Item

  @doc """
  A convenience function for doing an exact match search on a board game and
  retrieving info on the top result returned.
  """
  @spec board_game_info(String.t()) :: {:ok, %Item{}} | {:error, :no_results}
  def board_game_info(name) do
    search_result = Item.search(name, exact: true, type: ["boardgame"])

    case search_result do
      [] -> {:error, :no_results}
      [item | _] -> item |> Map.get(:id) |> Item.info()
    end
  end
end
