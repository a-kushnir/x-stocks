# frozen_string_literal: true

# Generates country flag link
class CountryFlag
  COUNTRY_FLAGS = {
    'austria' => 'at',
    'australia' => 'au',
    'belgium' => 'be',
    'brazil' => 'br',
    'canada' => 'ca',
    'ca' => 'ca',
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

  def code(country)
    COUNTRY_FLAGS[country.to_s.downcase]&.upcase
  end

  def link(country, size:)
    code = code(country)
    "/img/flags-iso/flat/#{size}/#{code}.png" if code
  end
end
