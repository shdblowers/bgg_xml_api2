defmodule BggXmlApi2.Collection do
  import SweetXml

  alias BggXmlApi2.Api, as: BggApi

  def game_names(username) do
    result =
      "/collection?username=#{username}&own=1&excludesubtype=boardgameexpansion&brief=1"
      |> get_collection()
      |> Map.get(:body)
      |> xpath(~x"//item/name/text()"l)
      |> Enum.map(&List.to_string/1)

    {:ok, result}
  end

  defp get_collection(url) do
    get_collection(url, BggApi.get!(url))
  end

  defp get_collection(url, %HTTPoison.Response{status_code: 202}) do
    Process.sleep(500)
    get_collection(url, BggApi.get!(url))
  end

  defp get_collection(_url, %HTTPoison.Response{status_code: 200} = response) do
    response
  end

  defp get_collection(_url, response), do: response
end
