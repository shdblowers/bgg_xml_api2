defmodule BggXmlApi2 do
  alias BggXmlApi2.Item

  @doc """
  A convenience function for doing an exact match search on a board game and
  retrieving info on the top result returned.
  """
  @spec board_game_info(String.t()) :: %BggXmlApi2.Item{}
  def board_game_info(name) do
    name
    |> Item.search(exact: true, type: ["boardgame"])
    |> Kernel.hd()
    |> Map.get(:id)
    |> Item.info()
  end
end
