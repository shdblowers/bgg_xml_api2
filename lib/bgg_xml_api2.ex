defmodule BggXmlApi2 do

  alias BggXmlApi2.Api, as: BggApi

  def search(query, opts \\ []) do
    BggApi.get!("/search?query=#{query}")
  end
end
