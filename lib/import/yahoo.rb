require 'net/http'

module Import
  class Yahoo < Base

    BASE_URL = 'https://finance.yahoo.com'

    def retrieve(symbol)
      load_text(quote_url(symbol))
    end

    private

    def quote_url(symbol)
      "#{BASE_URL}/quote/#{symbol}"
    end

  end
end
