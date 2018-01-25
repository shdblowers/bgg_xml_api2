defmodule BggXmlApi2.FamilyTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias BggXmlApi2.Family

  setup_all do
    HTTPoison.start()
  end

  test "family info" do
    use_cassette "camels_info" do
      assert Family.info("6480") ==
               {:ok,
                %Family{
                  id: "6480",
                  name: "Animals: Camels",
                  type: "boardgamefamily"
                }}
    end
  end
end
