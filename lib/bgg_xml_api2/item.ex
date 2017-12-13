defmodule BggXmlApi2.Item do
  @moduledoc """
  A set of functions for searching and retrieving information on Items.
  """
  
  import SweetXml
  
  alias BggXmlApi2.Api, as: BggApi

  @enforce_keys [:id, :name]
  
  defstruct [
    :id,
    :name,
    :type,
    :year_published,
    :thumbnail,
    :description,
    :min_players,
    :max_players
  ]
  
  @doc """
  Search for an Item based on `name`.
  """
  def search(name, opts \\ []) do
    exact_search = Keyword.get(opts, :exact, false)

    exact = if (exact_search), do: "&exact=1", else: ""

    "/search?query=#{URI.encode(name)}#{exact}"
    |> BggApi.get!()
    |> Map.get(:body)
    |> retrieve_item_details(~x"//item"l)
    |> Enum.map(&process_item/1)
  end

  @doc """
  Retrieve information on an Item based on `id`.
  """
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
      id: ~x"./@id" |> transform_by(&if_charlist_convert_to_string/1), 
      name: ~x"./name[@type='primary']/@value" |> transform_by(&if_charlist_convert_to_string/1),
      type: ~x"./@type" |> transform_by(&if_charlist_convert_to_string/1), 
      year_published: ~x"./yearpublished/@value" |> transform_by(&if_charlist_convert_to_string/1),
      thumbnail: ~x"./thumbnail/text()" |> transform_by(&if_charlist_convert_to_string/1),
      description: ~x"./description/text()"l |> transform_by(&Enum.join/1),
      min_players: ~x"./minplayers/@value" |> transform_by(&if_charlist_convert_to_integer/1),
      max_players: ~x"./maxplayers/@value" |> transform_by(&if_charlist_convert_to_integer/1)
    )
  end

  defp process_item(item) do
    item = Map.update(item, :description, nil, &(if &1 == "" do nil else &1 end))
    struct(__MODULE__, item)
  end

  defp if_charlist_convert_to_string(possible_charlist) do
    if is_list(possible_charlist) do List.to_string(possible_charlist) else possible_charlist end
  end

  defp if_charlist_convert_to_integer(possible_charlist) do
    if is_list(possible_charlist) do List.to_integer(possible_charlist) else possible_charlist end
  end

end