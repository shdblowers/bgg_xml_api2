defmodule BggXmlApi2.Item do
  @moduledoc """
  A set of functions for searching and retrieving information on Items.
  """

  import SweetXml

  alias BggXmlApi2.Api, as: BggApi

  @enforce_keys [:id, :name, :type, :year_published]

  defstruct [
    :id,
    :name,
    :type,
    :year_published,
    :image,
    :thumbnail,
    :description,
    :min_players,
    :max_players,
    :playing_time,
    :min_play_time,
    :max_play_time,
    :average_rating,
    :average_weight,
    categories: [],
    mechanics: [],
    families: [],
    expansions: [],
    designers: [],
    artists: [],
    publishers: []
  ]

  @doc """
  Search for an Item based on `name`.

  ## Options

  Options can be:

  * `:exact` - if set to true an exact match search on the name will be done

  * `:type` - a list of strings where each one is a type of item to search for,
    the types of items available are rpgitem, videogame, boardgame,
    boardgameaccessory or boardgameexpansion

  """
  @spec search(String.t(), keyword) :: [%__MODULE__{}]
  def search(name, opts \\ []) do
    name
    |> build_search_query_string(opts)
    |> BggApi.get!()
    |> Map.get(:body)
    |> retrieve_multi_item_details(~x"//item"l)
    |> Enum.map(&process_item/1)
  end

  @doc """
  Retrieve information on an Item based on `id`.
  """
  @spec info(String.t()) :: {:ok, %BggXmlApi2.Item{}} | {:error, :no_results}
  def info(id) do
    item =
      "/thing?stats=1&id=#{id}"
      |> BggApi.get!()
      |> Map.get(:body)
      |> retrieve_item_details(~x"//item")

    case item do
      {:ok, item} -> {:ok, process_item(item)}
      {:error, :no_results} -> {:error, :no_results}
    end
  end

  defp build_search_query_string(name, opts) do
    exact_search = Keyword.get(opts, :exact, false)
    exact = if exact_search, do: "&exact=1", else: ""

    type_search = Keyword.get(opts, :type, false)
    type = if type_search, do: "&type=#{Enum.join(type_search, ",")}", else: ""

    "/search?query=#{URI.encode(name)}#{exact}#{type}"
  end

  defp retrieve_item_details(xml, path_to_item) do
    case xpath(xml, path_to_item) do
      nil -> {:error, :no_results}
      item -> {:ok, rid(item)}
    end
  end

  defp retrieve_multi_item_details(xml, path_to_items) do
    xml
    |> xpath(path_to_items)
    |> Enum.map(&rid/1)
  end

  defp rid(item) do
    %{
      id:
        item
        |> xpath(~x"./@id")
        |> if_charlist_convert_to_string(),
      name:
        item
        |> xpath(~x"./name[@type='primary']/@value")
        |> if_charlist_convert_to_string(),
      type:
        item
        |> xpath(~x"./@type")
        |> if_charlist_convert_to_string(),
      year_published:
        item
        |> xpath(~x"./yearpublished/@value")
        |> if_charlist_convert_to_string(),
      image:
        item
        |> xpath(~x"./image/text()")
        |> if_charlist_convert_to_string(),
      thumbnail:
        item
        |> xpath(~x"./thumbnail/text()")
        |> if_charlist_convert_to_string(),
      description:
        item
        |> xpath(~x"./description/text()"l)
        |> Enum.join(),
      min_players:
        item
        |> xpath(~x"./minplayers/@value")
        |> if_charlist_convert_to_integer(),
      max_players:
        item
        |> xpath(~x"./maxplayers/@value")
        |> if_charlist_convert_to_integer(),
      playing_time:
        item
        |> xpath(~x"./playingtime/@value")
        |> if_charlist_convert_to_integer(),
      min_play_time:
        item
        |> xpath(~x"./minplaytime/@value")
        |> if_charlist_convert_to_integer(),
      max_play_time:
        item
        |> xpath(~x"./maxplaytime/@value")
        |> if_charlist_convert_to_integer(),
      average_rating:
        item
        |> xpath(~x"./statistics/ratings/average/@value")
        |> if_charlist_convert_to_float(),
      average_weight:
        item
        |> xpath(~x"./statistics/ratings/averageweight/@value")
        |> if_charlist_convert_to_float(),
      categories:
        item
        |> xpath(~x"./link[@type='boardgamecategory']/@value"l)
        |> Enum.map(&if_charlist_convert_to_string/1),
      mechanics:
        item
        |> xpath(~x"./link[@type='boardgamemechanic']/@value"l)
        |> Enum.map(&if_charlist_convert_to_string/1),
      families:
        item
        |> xpath(~x"./link[@type='boardgamefamily']/@value"l)
        |> Enum.map(&if_charlist_convert_to_string/1),
      expansions:
        item
        |> xpath(~x"./link[@type='boardgameexpansion']/@value"l)
        |> Enum.map(&if_charlist_convert_to_string/1),
      designers:
        item
        |> xpath(~x"./link[@type='boardgamedesigner']/@value"l)
        |> Enum.map(&if_charlist_convert_to_string/1),
      artists:
        item
        |> xpath(~x"./link[@type='boardgameartist']/@value"l)
        |> Enum.map(&if_charlist_convert_to_string/1),
      publishers:
        item
        |> xpath(~x"./link[@type='boardgamepublisher']/@value"l)
        |> Enum.map(&if_charlist_convert_to_string/1)
    }
  end

  defp process_item(%{description: ""} = item) do
    item = %{item | description: nil}

    struct(__MODULE__, item)
  end

  defp process_item(item) do
    item = Map.update(item, :description, nil, &HtmlEntities.decode/1)

    struct(__MODULE__, item)
  end

  defp if_charlist_convert_to_string(possible_charlist) do
    if is_list(possible_charlist) do
      List.to_string(possible_charlist)
    else
      possible_charlist
    end
  end

  defp if_charlist_convert_to_integer(possible_charlist) do
    if is_list(possible_charlist) do
      List.to_integer(possible_charlist)
    else
      possible_charlist
    end
  end

  defp if_charlist_convert_to_float(possible_charlist) do
    if is_list(possible_charlist) do
      List.to_float(possible_charlist)
    else
      possible_charlist
    end
  end
end
