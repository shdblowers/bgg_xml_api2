defmodule BggXmlApi2 do

  import SweetXml

  alias BggXmlApi2.Api, as: BggApi

  def search(query, opts \\ []) do
    "/search?query=#{query}" 
    |> BggApi.get!()
    |> Map.get(:body)
    |> xpath(~x"//item"l, name: ~x"./name[@type='primary']/@value", id: ~x"./@id")
  end
end
