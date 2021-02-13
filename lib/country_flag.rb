# frozen_string_literal: true

# Generates country flag link
class CountryFlag
  BASE_URL = 'https://www.countryflags.io/'
  COUNTRY_FLAGS = {
    'austria' => 'at',
    'australia' => 'au',
    'belgium' => 'be',
    'brazil' => 'br',
    'canada' => 'ca',
    'switzerland' => 'ch',
    'china' => 'cn',
    'czech republic' => 'cz',
    'germany' => 'de',
    'denmark' => 'dk',
    'estonia' => 'ee',
    'spain' => 'sp',
    'eu' => 'eu',
    'finland' => 'fl',
    'france' => 'fr',
    'united kingdom' => 'gb',
    'uk' => 'gb',
    'greece' => 'gr',
    'hong kong' => 'hk',
    'india' => 'in',
    'iceland' => 'is',
    'italy' => 'it',
    'japan' => 'jp',
    'lithuania' => 'lt',
    'latvia' => 'lv',
    'mexico' => 'mx',
    'netherlands' => 'nl',
    'norway' => 'no',
    'new zealand' => 'nz',
    'poland' => 'pl',
    'russian federation' => 'ru',
    'russia' => 'ru',
    'singapore' => 'sg',
    'ukraine' => 'ua',
    'us' => 'us',
    'usa' => 'us',
    'united states' => 'us',
    'united states of america' => 'us'
  }.freeze

  def link(country, size:)
    code = COUNTRY_FLAGS[country.to_s.downcase]
    "#{BASE_URL}#{code}/flat/#{size}.png" if code
  end
end
