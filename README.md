# BggXmlApi2

[![Build Status](https://travis-ci.org/shdblowers/bgg_xml_api2.svg?branch=master)](https://travis-ci.org/shdblowers/bgg_xml_api2)

Details about the BGG API is found on their [wiki page](https://boardgamegeek.com/wiki/page/BGG_XML_API2).

## Installation

This package is available via [Hex](https://hex.pm), the package can be installed by adding `bgg_xml_api2` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:bgg_xml_api2, "~> 0.1.0"}
  ]
end
```

Online documentation can be found at [https://hexdocs.pm/bgg_xml_api2](https://hexdocs.pm/bgg_xml_api2).

## Getting Started

There are convenience function located in the `BggXmlApi2` module, which are a good place to get started.

### Board Game Info

For simply retrieving info on a board game via its name, this function can be used, which first does an exact match search on the name given and then retrieves details on the result. Here is an example:

```elixir
iex(1)> BggXmlApi2.board_game_info("Terraforming Mars")
{:ok,
 %BggXmlApi2.Item{
   id: "167791",
   name: "Terraforming Mars",
   type: "boardgame",
   year_published: "2016",
   description: "In the 2400s, mankind...",
   min_players: 1,
   max_players: 5,
   min_play_time: 120,
   playing_time: 120,
   max_play_time: 120,
   thumbnail: "https://cf.geekdo-images.com/images/pic3536616_t.jpg",
   image: "https://cf.geekdo-images.com/images/pic3536616.jpg",
   average_rating: 8.38334
  }
}
```

For anything more complex, look at the functions available for each resource which have a corresponding module, e.g. `BggXmlApi2.Item`.

## (Un)License

This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or
distribute this software, either in source code form or as a compiled
binary, for any purpose, commercial or non-commercial, and by any
means.

In jurisdictions that recognize copyright laws, the author or authors
of this software dedicate any and all copyright interest in the
software to the public domain. We make this dedication for the benefit
of the public at large and to the detriment of our heirs and
successors. We intend this dedication to be an overt act of
relinquishment in perpetuity of all present and future rights to this
software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

For more information, please refer to <http://unlicense.org>
