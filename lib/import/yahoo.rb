require 'net/http'

module Import
  class Yahoo

    BASE_URL = 'https://finance.yahoo.com'

    def retrieve(symbol)
      response = Net::HTTP.get_response(uri(symbol))
      if response.is_a?(Net::HTTPSuccess)
        response.body
      end
    end

    private

    def uri(symbol)
      URI("#{BASE_URL}/quote/#{symbol}")
    end

  end
end
