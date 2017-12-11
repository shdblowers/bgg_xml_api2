defmodule BggXmlApi2 do

  import SweetXml

  alias BggXmlApi2.Api, as: BggApi

  def search(query, opts \\ []) do
    "/search?query=#{query}"
    |> BggApi.get!()
    |> Map.get(:body)
    |> xpath(~x"//item"l, id: ~x"./@id", name: ~x"./name[@type='primary']/@value", type: ~x"./@type", year_published: ~x"./yearpublished/@value")
  end

  def thing(id) do
    "/thing?id=#{id}"
    |> BggApi.get!()
    |> Map.get(:body)
    |> xpath(~x"//item", id: ~x"./@id", name: ~x"./name[@type='primary']/@value", min_players: ~x"./minplayers/@value", max_players: ~x"./maxplayers/@value")
  end
end
