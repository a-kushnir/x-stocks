module Etl
  module Extract
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
end
