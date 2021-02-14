# frozen_string_literal: true

# Generates country name
class CountryName
  COUNTRY_NAMES = {
    'ca' => 'Canada',
    'uk' => 'United Kingdom',
    'us' => 'United States',
    'usa' => 'United States',
    'united states of america' => 'United States'
  }.freeze

  def name(country)
    COUNTRY_NAMES[country.to_s.downcase] || country
  end
end
