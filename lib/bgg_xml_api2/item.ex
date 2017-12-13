defmodule BggXmlApi2.Item do
  
  import SweetXml
  
  alias BggXmlApi2.Api, as: BggApi

  @enforce_keys [:id, :name]
  
  defstruct [
    :id,
    :name,
    :type,
    :year_published,
    :min_players,
    :max_players
  ]
  
  def search(query, opts \\ []) do
    exact_search = Keyword.get(opts, :exact, false)

    exact = if (exact_search), do: "&exact=1", else: ""

    "/search?query=#{URI.encode(query)}#{exact}"
    |> BggApi.get!()
    |> Map.get(:body)
    |> retrieve_item_details(~x"//item"l)
    |> Enum.map(&(struct(__MODULE__, &1)))
  end

  def info(id, opts \\ []) do
    result = 
      "/thing?id=#{id}"
      |> BggApi.get!()
      |> Map.get(:body)
      |> retrieve_item_details(~x"//item")

    struct(__MODULE__, result)
  end

  defp retrieve_item_details(xml, path_to_item) do
    xpath(
      xml,
      path_to_item, 
      id: ~x"./@id", 
      name: ~x"./name[@type='primary']/@value", 
      min_players: ~x"./minplayers/@value",
      max_players: ~x"./maxplayers/@value",
      type: ~x"./@type", 
      year_published: ~x"./yearpublished/@value"
    )
  end

end