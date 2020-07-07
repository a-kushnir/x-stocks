require 'net/http'

module Import
  class Iexapis < Base

    BASE_URL = 'https://cloud.iexapis.com/stable'
    IEXAPIS_KEY = ENV['IEXAPIS_KEY']

    def company(symbol)
      load_json(company_url(symbol))
    end

    private

    def company_url(symbol)
      "#{BASE_URL}/stock/" + symbol + "/company?token=" + IEXAPIS_KEY;
    end

  end
end
