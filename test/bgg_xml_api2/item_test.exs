defmodule BggXmlApi2.ItemTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias BggXmlApi2.Item

  setup_all do
    HTTPoison.start
  end

  test "basic search" do
    use_cassette "basic_search_lords_of_waterdeep" do
      assert Item.search("Lords of Waterdeep") == [
        %BggXmlApi2.Item{id: '110327', max_players: nil, min_players: nil, name: 'Lords of Waterdeep', type: 'boardgame', year_published: '2012'},
        %BggXmlApi2.Item{id: '122996', max_players: nil, min_players: nil, name: 'Lords of Waterdeep: Inevitable Betrayal Promo Card', type: 'boardgame', year_published: '2012'},
        %BggXmlApi2.Item{id: '146704', max_players: nil, min_players: nil, name: 'Lords of Waterdeep: Rapid Expansion Promo Card', type: 'boardgame', year_published: '2013'},
        %BggXmlApi2.Item{id: '134342', max_players: nil, min_players: nil, name: 'Lords of Waterdeep: Scoundrels of Skullport', type: 'boardgame', year_published: '2013'},
        %BggXmlApi2.Item{id: '122996', max_players: nil, min_players: nil, name: 'Lords of Waterdeep: Inevitable Betrayal Promo Card', type: 'boardgameexpansion', year_published: '2012'},
        %BggXmlApi2.Item{id: '146704', max_players: nil, min_players: nil, name: 'Lords of Waterdeep: Rapid Expansion Promo Card', type: 'boardgameexpansion', year_published: '2013'},
        %BggXmlApi2.Item{id: '134342', max_players: nil, min_players: nil, name: 'Lords of Waterdeep: Scoundrels of Skullport', type: 'boardgameexpansion', year_published: '2013'},
        %BggXmlApi2.Item{id: '151172', max_players: nil, min_players: nil, name: 'Lords of Waterdeep', type: 'videogame', year_published: nil},
        %BggXmlApi2.Item{id: '234749', max_players: nil, min_players: nil, name: 'Lords of Waterdeep - Undermountain', type: 'videogame', year_published: nil},
        %BggXmlApi2.Item{id: '234750', max_players: nil, min_players: nil, name: 'Lords of Waterdeep: Skullport expansion', type: 'videogame', year_published: nil}
      ]
    end
  end

  test "exact search" do
    use_cassette "exact_search_zombicide" do
      assert Item.search("Zombicide", exact: true) == 
        [
          %BggXmlApi2.Item{
            id: '113924', 
            max_players: nil, 
            min_players: nil,   
            name: 'Zombicide', 
            type: 'boardgame', 
            year_published: '2012'
          }
        ]
    end
  end

  test "get game info" do
    use_cassette "info_on_jaipur" do
      assert Item.info("54043") == %BggXmlApi2.Item{id: '54043', max_players: '2', min_players: '2', name: 'Jaipur', type: nil, year_published: nil}
    end
  end
end