use Mix.Config

config :exvcr,
  vcr_cassette_library_dir: "fixtures/vcr_cassettes",
  custom_cassette_library_dir: "fixtures/custom_cassettes"
