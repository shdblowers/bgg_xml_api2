defmodule BggXmlApi2.Collection do

  import SweetXml

  alias BggXmlApi2.Api, as: BggApi

  def game_names(username) do
    "/collection?username=#{username}&own=1&excludesubtype=boardgameexpansion&brief=1"
    |> BggApi.get!()
    |> Map.get(:body)
    |> xpath(~x"//item/name/text()"l)
  end
end