defmodule BggXmlApi2.ItemTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias BggXmlApi2.Item

  setup_all do
    HTTPoison.start
  end

  test "basic search" do
    use_cassette "basic_search_lords_of_waterdeep" do
      item_search_results = Item.search("Lords of Waterdeep")
      assert Enum.member?(
        item_search_results,
        %BggXmlApi2.Item{
          id: "110327", 
          max_players: nil, 
          min_players: nil, 
          name: "Lords of Waterdeep", 
          type: "boardgame", 
          year_published: "2012",
          description: nil,
          thumbnail: nil
        }
      )
    end
  end

  test "exact search" do
    use_cassette "exact_search_zombicide" do
      assert Item.search("Zombicide", exact: true) == 
        [
          %BggXmlApi2.Item{
            id: "113924", 
            max_players: nil, 
            min_players: nil,   
            name: "Zombicide", 
            type: "boardgame", 
            year_published: "2012",
            description: nil,
            thumbnail: nil
          }
        ]
    end
  end

  test "get game info" do
    use_cassette "info_on_jaipur" do
      assert Item.info("54043") == 
      %BggXmlApi2.Item{
        id: "54043",
        name: "Jaipur",
        type: "boardgame",
        year_published: "2009",
        description: jaipur_description(),
        thumbnail: "https://cf.geekdo-images.com/images/pic725500_t.jpg",
        min_players: 2, 
        max_players: 2
      }
    end
  end

  defp jaipur_description() do
    "Jaipur, capital of Rajasthan. You are one of the two most powerful traders in the city.&#10;&#10;But that's not enough for you, because only the merchant with two Seals of Excellence will have the privilege of being invited to the Maharaja's court.&#10;&#10;You are therefore going to have to do better than your direct competitor by buying, exchanging and selling at better prices, all while keeping an eye on both your camel herds.&#10;&#10;A card game for two seasoned traders!&#10;&#10;When it's your turn, you can either take or sell cards.&#10;&#10;If you take cards, you have to choose between taking all the camels, taking 1 card from the market or swapping 2 to 5 cards between the market and your cards.&#10;&#10;If you sell cards, you get to sell only one type of good per turn, and you get as many chips from that good as you sold cards. The chips' values decrease as the game progresses, so you'd better hurry ! But, on the other hand, you get increasingly high rewards for selling 3, 4, or 5 cards of the same good at a time, so you'd better wait!&#10;&#10;You can't sell camels, but they're paramount for trading and they're also worth a little something at the end of the round, enough sometimes to secure the win, so you have to use them smartly.&#10;&#10;Jaipur is a fast-paced card game, a blend of tactics, risk and luck.&#10;&#10;"
  end
end