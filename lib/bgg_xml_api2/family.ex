defmodule BggXmlApi2.Family do
  @moduledoc """
  Relating to families of things on BGG.
  """

  import SweetXml

  alias BggXmlApi2.Api, as: BggApi

  @enforce_keys [:id, :name, :type]

  defstruct [
    :id,
    :name,
    :type,
    :description,
    :image,
    :thumbnail
  ]

  def info(id) do
    family =
      "/family?id=#{id}"
      |> BggApi.get!()
      |> Map.get(:body)
      |> retrieve_family_details()

    {:ok, struct(__MODULE__, family)}
  end

  defp retrieve_family_details(xml) do
    xml
    |> xpath(~x"//item")
    |> rfd()
  end

  defp rfd(family) do
    %{
      id:
        family
        |> xpath(~x"./@id")
        |> if_charlist_convert_to_string(),
      name:
        family
        |> xpath(~x"./name[@type='primary']/@value")
        |> if_charlist_convert_to_string(),
      type:
        family
        |> xpath(~x"./@type")
        |> if_charlist_convert_to_string()
    }
  end

  defp if_charlist_convert_to_string(possible_charlist) do
    if is_list(possible_charlist) do
      List.to_string(possible_charlist)
    else
      possible_charlist
    end
  end
end
