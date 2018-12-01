defmodule BggXmlApi2.ItemTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias BggXmlApi2.Item

  setup_all do
    HTTPoison.start()
  end

  describe "search" do
    test "basic search" do
      use_cassette "basic_search_lords_of_waterdeep" do
        {:ok, item_search_results} = Item.search("Lords of Waterdeep")

        assert Enum.member?(item_search_results, %BggXmlApi2.Item{
                 id: "110327",
                 name: "Lords of Waterdeep",
                 type: "boardgame",
                 year_published: "2012"
               })
      end
    end

    test "when search finds nothing it will return empty list" do
      use_cassette "no_results_search" do
        assert Item.search("F3bnu5yca2mgFZ1J") == {:ok, []}
      end
    end

    test "exact search" do
      use_cassette "exact_search_zombicide" do
        assert Item.search("Zombicide", exact: true) ==
                 {:ok,
                  [
                    %BggXmlApi2.Item{
                      id: "113924",
                      name: "Zombicide",
                      type: "boardgame",
                      year_published: "2012"
                    }
                  ]}
      end
    end

    test "giving the type in the search will filter by that type" do
      use_cassette "type_search_eldritch_horror" do
        {:ok, result} = Item.search("Eldritch Horror", type: ["boardgame"])

        assert Enum.all?(result, &(&1.type == "boardgame"))
      end
    end
  end

  describe "info" do
    test "get game info" do
      use_cassette "info_on_jaipur" do
        assert Item.info("54043") ==
                 {:ok,
                  %BggXmlApi2.Item{
                    id: "54043",
                    name: "Jaipur",
                    type: "boardgame",
                    year_published: "2009",
                    description: jaipur_description(),
                    image: "https://cf.geekdo-images.com/images/pic725500.jpg",
                    thumbnail:
                      "https://cf.geekdo-images.com/images/pic725500_t.jpg",
                    min_players: 2,
                    max_players: 2,
                    suggested_num_players: %{
                      "1" => %{best: 0, not_recommended: 148, recommended: 0},
                      "2" => %{best: 186, not_recommended: 1, recommended: 9},
                      "2+" => %{best: 5, not_recommended: 127, recommended: 11}
                    },
                    playing_time: 30,
                    min_play_time: 30,
                    max_play_time: 30,
                    average_rating: 7.53774,
                    average_weight: 1.5312,
                    categories: ["Animals", "Card Game"],
                    mechanics: [
                      "Card Drafting",
                      "Hand Management",
                      "Set Collection"
                    ],
                    families: [
                      "Animals: Camels",
                      "Asian Theme",
                      "Country: India"
                    ],
                    designers: ["Sébastien Pauchon"],
                    artists: ["Alexandre Roche"],
                    publishers: [
                      "GameWorks SàRL",
                      "Asmodee",
                      "cutia.ro",
                      "Esdevium",
                      "Kaissa Chess & Games",
                      "Rebel",
                      "Siam Board Games"
                    ]
                  }}
      end
    end

    test "get info on a non-existant ID will return :error with a message" do
      use_cassette "info_on_nothing" do
        assert Item.info("XxX") == {:error, :no_results}
      end
    end
  end

  describe "hot items" do
    test "get hot boardgame items" do
      use_cassette "hot_items" do
        {:ok, hot_items} = Item.hot_items(type: "boardgame")

        assert hd(hot_items) == %BggXmlApi2.Item{
                 id: "245931",
                 name: "Nētā-Tanka",
                 type: "boardgame",
                 year_published: "2018",
                 thumbnail:
                   "https://cf.geekdo-images.com/thumb/img/KCuoGe7cTIWEp4G4yCmpTjZBn6s=/fit-in/200x150/pic4061828.jpg"
               }
      end
    end

    test "default type is boardgame" do
      use_cassette "hot_items" do
        assert Item.hot_items() == Item.hot_items(type: "boardgame")
      end
    end
  end

  defp jaipur_description() do
    "Jaipur, capital of Rajasthan. You are one of the two most powerful traders in the city.\n\nBut that's not enough for you, because only the merchant with two Seals of Excellence will have the privilege of being invited to the Maharaja's court.\n\nYou are therefore going to have to do better than your direct competitor by buying, exchanging and selling at better prices, all while keeping an eye on both your camel herds.\n\nA card game for two seasoned traders!\n\nWhen it's your turn, you can either take or sell cards.\n\nIf you take cards, you have to choose between taking all the camels, taking 1 card from the market or swapping 2 to 5 cards between the market and your cards.\n\nIf you sell cards, you get to sell only one type of good per turn, and you get as many chips from that good as you sold cards. The chips' values decrease as the game progresses, so you'd better hurry ! But, on the other hand, you get increasingly high rewards for selling 3, 4, or 5 cards of the same good at a time, so you'd better wait!\n\nYou can't sell camels, but they're paramount for trading and they're also worth a little something at the end of the round, enough sometimes to secure the win, so you have to use them smartly.\n\nJaipur is a fast-paced card game, a blend of tactics, risk and luck.\n\n"
  end
end
