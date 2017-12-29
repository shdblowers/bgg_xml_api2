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
    :thumbnail,
    :description,
    :min_players,
    :max_players,
    :playing_time,
    :min_play_time,
    :max_play_time
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
  @spec info(String.t()) :: %__MODULE__{}
  def info(id) do
    "/thing?id=#{id}"
    |> BggApi.get!()
    |> Map.get(:body)
    |> retrieve_item_details(~x"//item")
    |> process_item()
  end

  defp build_search_query_string(name, opts) do
    exact_search = Keyword.get(opts, :exact, false)
    exact = if exact_search, do: "&exact=1", else: ""

    type_search = Keyword.get(opts, :type, false)
    type = if type_search, do: "&type=#{Enum.join(type_search, ",")}", else: ""

    "/search?query=#{URI.encode(name)}#{exact}#{type}"
  end

  defp retrieve_item_details(xml, path_to_item) do
    xml
    |> xpath(path_to_item)
    |> rid()
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
        |> if_charlist_convert_to_integer()
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
end
