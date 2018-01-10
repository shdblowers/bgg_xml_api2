defmodule BggXmlApi2Test do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  setup_all do
    HTTPoison.start()
  end

  test "board game info convenience function" do
    use_cassette "search_and_info_on_scythe" do
      assert BggXmlApi2.board_game_info("Scythe") ==
               {:ok, %BggXmlApi2.Item{
                 id: "169786",
                 name: "Scythe",
                 type: "boardgame",
                 year_published: "2016",
                 description: scythe_description(),
                 image: "https://cf.geekdo-images.com/images/pic3163924.jpg",
                 thumbnail:
                   "https://cf.geekdo-images.com/images/pic3163924_t.jpg",
                 min_players: 1,
                 max_players: 5,
                 playing_time: 115,
                 min_play_time: 90,
                 max_play_time: 115,
                 average_rating: 8.29583,
                 categories: [
                   "Civilization",
                   "Economic",
                   "Fighting",
                   "Miniatures",
                   "Science Fiction",
                   "Territory Building"
                  ],
                  mechanics: [
                    "Area Control / Area Influence",
                    "Grid Movement",
                    "Simultaneous Action Selection",
                    "Variable Player Powers"
                  ],
                  families: [
                    "Alternate History",
                    "Components: Miniatures",
                    "Crowdfunding: Kickstarter",
                    "Scythe",
                    "Solitaire Games",
                    "Tableau Building"
                  ],
                  expansions: [
                    "Scythe: Invaders from Afar",
                    "Scythe: Promo Encounter Card #37",
                    "Scythe: Promo Encounter Card #38",
                    "Scythe: Promo Encounter Card #39",
                    "Scythe: Promo Encounter Card #40",
                    "Scythe: Promo Encounter Card #41",
                    "Scythe: Promo Encounter Card #42",
                    "Scythe: Promo Pack #1",
                    "Scythe: Promo Pack #2",
                    "Scythe: Promo Pack #3",
                    "Scythe: Promo Pack #4",
                    "Scythe: The Rise of Fenris",
                    "Scythe: The Wind Gambit"
                  ],
                  designers: ["Jamey Stegmaier"],
                  artists: ["Jakub Rozalski"],
                  publishers: [
                    "Stonemaier Games",
                    "Albi",
                    "Arclight",
                    "Crowd Games",
                    "Delta Vision Publishing",
                    "Feuerland Spiele",
                    "Fire on Board Jogos",
                    "Ghenos Games",
                    "Maldito Games",
                    "Matagot",
                    "Morning",
                    "PHALANX",
                    "Playfun Games"
                 ]
               }}
    end
  end

  test "when search finds nothing it will return error" do
    use_cassette "no_results_search" do
      assert BggXmlApi2.board_game_info("F3bnu5yca2mgFZ1J") ==
               {:error, :no_results}
    end
  end

  defp scythe_description() do
    "It is a time of unrest in 1920s Europa. The ashes from the first great war still darken the snow. The capitalistic city-state known simply as “The Factory”, which fueled the war with heavily armored mechs, has closed its doors, drawing the attention of several nearby countries.\n\nScythe is an engine-building game set in an alternate-history 1920s period. It is a time of farming and war, broken hearts and rusted gears, innovation and valor. In Scythe, each player represents a character from one of five factions of Eastern Europe who are attempting to earn their fortune and claim their faction's stake in the land around the mysterious Factory. Players conquer territory, enlist new recruits, reap resources, gain villagers, build structures, and activate monstrous mechs.\n\nEach player begins the game with different resources (power, coins, combat acumen, and popularity), a different starting location, and a hidden goal. Starting positions are specially calibrated to contribute to each faction’s uniqueness and the asymmetrical nature of the game (each faction always starts in the same place).\n\nScythe gives players almost complete control over their fate. Other than each player’s individual hidden objective card, the only elements of luck or variability are “encounter” cards that players will draw as they interact with the citizens of newly explored lands. Each encounter card provides the player with several options, allowing them to mitigate the luck of the draw through their selection. Combat is also driven by choices, not luck or randomness.\n\nScythe uses a streamlined action-selection mechanism (no rounds or phases) to keep gameplay moving at a brisk pace and reduce downtime between turns. While there is plenty of direct conflict for players who seek it, there is no player elimination.\n\nEvery part of Scythe has an aspect of engine-building to it. Players can upgrade actions to become more efficient, build structures that improve their position on the map, enlist new recruits to enhance character abilities, activate mechs to deter opponents from invading, and expand their borders to reap greater types and quantities of resources. These engine-building aspects create a sense of momentum and progress throughout the game. The order in which players improve their engine adds to the unique feel of each game, even when playing one faction multiple times.\n\n"
  end
end
