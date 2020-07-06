require 'net/http'

module Import
  class Iexapis

    BASE_URL = 'https://cloud.iexapis.com/stable'
    IEXAPIS_KEY = ENV['IEXAPIS_KEY']

    def company(symbol)
      load_json(company_url(symbol))
    end

    private

    def company_url(symbol)
      "#{BASE_URL}/stock/" + symbol + "/company?token=" + IEXAPIS_KEY;
    end

    def load_json(url)
      response = Net::HTTP.get_response(URI(url))
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      end
    end

  end
end
