defmodule BggXmlApi2.Item do
  
  import SweetXml
  
  alias BggXmlApi2.Api, as: BggApi

  @enforce_keys [:id, :name]
  
  defstruct [
    :id,
    :name,
    :type,
    :year_published,
    :description,
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
    |> Enum.map(&process_item/1)
  end

  def info(id, opts \\ []) do
    "/thing?id=#{id}"
    |> BggApi.get!()
    |> Map.get(:body)
    |> retrieve_item_details(~x"//item")
    |> process_item()
  end

  defp retrieve_item_details(xml, path_to_item) do
    xpath(
      xml,
      path_to_item, 
      id: ~x"./@id", 
      name: ~x"./name[@type='primary']/@value",
      type: ~x"./@type", 
      year_published: ~x"./yearpublished/@value",
      description: ~x"./description/text()"l |> transform_by(&Enum.join/1),
      min_players: ~x"./minplayers/@value",
      max_players: ~x"./maxplayers/@value"
    )
  end

  defp process_item(item) do
    item = Map.update(item, :description, nil, &(if &1 == "" do nil else &1 end))
    struct(__MODULE__, item)
  end

end