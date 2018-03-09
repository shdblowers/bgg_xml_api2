defmodule BggXmlApi2.CollectionTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias BggXmlApi2.Collection

  setup_all do
    HTTPoison.start()
  end

  test "retrieve game names from collection" do
    use_cassette "shdb_collection" do
      assert Collection.game_names("shdb") ==
               {:ok,
                [
                  "Android: Netrunner",
                  "Arkham Horror: The Card Game",
                  "Ascension: Apprentice Edition",
                  "Betrayal at House on the Hill",
                  "The Castles of Burgundy",
                  "Codenames: Pictures",
                  "Cthulhu Fluxx",
                  "Dead of Winter: A Crossroads Game",
                  "Dixit",
                  "Dominion",
                  "Eldritch Horror",
                  "Elixir",
                  "A Game of Thrones: The Card Game (Second Edition)",
                  "Hive",
                  "Jaipur",
                  "King of Tokyo",
                  "The Lord of the Rings: The Card Game",
                  "Lords of Waterdeep",
                  "Monopoly",
                  "Onitama",
                  "The Resistance: Avalon",
                  "Risk: Balance of Power",
                  "Roll for the Galaxy",
                  "Scythe",
                  "Specter Ops",
                  "Star Realms",
                  "Star Wars: X-Wing Miniatures Game",
                  "Suburbia",
                  "Ticket to Ride: Europe",
                  "Zombicide",
                  "Zombicide: Black Plague"
                ]}
    end
  end
end
