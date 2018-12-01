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
    publishers: [],
    suggested_num_players: %{}
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
  @spec search(String.t(), keyword) :: {:ok, [%__MODULE__{}]} | :error
  def search(name, opts \\ []) do
    result =
      name
      |> build_search_query_string(opts)
      |> BggApi.get()

    case result do
      {:ok, response} ->
        return =
          response
          |> Map.get(:body)
          |> retrieve_multi_item_details(~x"//item"l)
          |> Enum.map(&process_item/1)

        {:ok, return}

      _ ->
        :error
    end
  end

  @spec hot_items(keyword) :: {:ok, [%__MODULE__{}]} | :error
  def hot_items(opts \\ []) do
    type = Keyword.get(opts, :type, "boardgame")
    url = "/hot?type=#{type}"

    case BggApi.get(url) do
      {:ok, response} ->
        return =
          response
          |> Map.get(:body)
          |> retrieve_multi_item_details(~x"//item"l)
          |> Enum.map(fn item -> Map.put(item, :type, type) end)
          |> Enum.map(&process_item/1)

        {:ok, return}

      _ ->
        :error
    end
  end

  @doc """
  Retrieve information on an Item based on `id`.
  """
  @spec info(String.t()) :: {:ok, %BggXmlApi2.Item{}} | {:error, :no_results}
  def info(id) do
    with {:ok, response} <- BggApi.get("/thing?stats=1&id=#{id}"),
         body <- Map.get(response, :body),
         {:ok, item} <- retrieve_item_details(body, ~x"//item") do
      {:ok, process_item(item)}
    else
      {:error, _} ->
        {:error, :no_results}
    end
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
      id: xpath(item, ~x"./@id"s),
      name:
        item
        |> multi_xpaths([~x"./name[@type='primary']/@value", ~x"./name/@value"])
        |> if_charlist_convert_to_string(),
      type: xpath(item, ~x"./@type"s),
      year_published:
        xpath(item, ~x"./yearpublished/@value")
        |> if_charlist_convert_to_string(),
      image:
        item
        |> xpath(~x"./image/text()")
        |> if_charlist_convert_to_string(),
      thumbnail:
        item
        |> multi_xpaths([~x"./thumbnail/text()", ~x"./thumbnail/@value"])
        |> if_charlist_convert_to_string(),
      description:
        item
        |> xpath(~x"./description/text()"Sl)
        |> Enum.join(),
      min_players:
        item
        |> xpath(~x"./minplayers/@value"Io),
      max_players:
        item
        |> xpath(~x"./maxplayers/@value"Io),
      suggested_num_players:
        item
        |> xpath(
          ~x"./poll[@name='suggested_numplayers']/results"l,
          num_players: ~x"@numplayers"s,
          results: [~x"./result"l, value: ~x"@value"s, votes: ~x"@numvotes"i]
        )
        |> simplify_suggested_num_players_structure(),
      playing_time: xpath(item, ~x"./playingtime/@value"Io),
      min_play_time: xpath(item, ~x"./minplaytime/@value"Io),
      max_play_time: xpath(item, ~x"./maxplaytime/@value"Io),
      average_rating: xpath(item, ~x"./statistics/ratings/average/@value"Fo),
      average_weight:
        xpath(item, ~x"./statistics/ratings/averageweight/@value"Fo),
      categories: xpath(item, ~x"./link[@type='boardgamecategory']/@value"Sl),
      mechanics: xpath(item, ~x"./link[@type='boardgamemechanic']/@value"Sl),
      families: xpath(item, ~x"./link[@type='boardgamefamily']/@value"Sl),
      expansions: xpath(item, ~x"./link[@type='boardgameexpansion']/@value"Sl),
      designers: xpath(item, ~x"./link[@type='boardgamedesigner']/@value"Sl),
      artists: xpath(item, ~x"./link[@type='boardgameartist']/@value"Sl),
      publishers: xpath(item, ~x"./link[@type='boardgamepublisher']/@value"Sl)
    }
  end

  defp multi_xpaths(item, xpaths) do
    Enum.find_value(xpaths, fn x ->
      xpath(item, x)
    end)
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

  defp build_search_query_string(name, opts) do
    exact_search = Keyword.get(opts, :exact, false)
    exact = if exact_search, do: "&exact=1", else: ""

    type_search = Keyword.get(opts, :type, false)
    type = if type_search, do: "&type=#{Enum.join(type_search, ",")}", else: ""

    "/search?query=#{URI.encode(name)}#{exact}#{type}"
  end

  defp simplify_suggested_num_players_structure(player_counts) do
    player_counts
    |> Enum.map(fn %{num_players: num_players, results: results} ->
      simplified_results = simplify_results(results)
      {num_players, simplified_results}
    end)
    |> Enum.into(%{})
  end

  defp simplify_results(results) do
    results
    |> Enum.map(fn
      %{value: "Best", votes: votes} -> {:best, votes}
      %{value: "Recommended", votes: votes} -> {:recommended, votes}
      %{value: "Not Recommended", votes: votes} -> {:not_recommended, votes}
    end)
    |> Enum.into(%{})
  end
end
