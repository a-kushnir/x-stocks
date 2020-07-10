module Etl
  module Extract
    class Yahoo < Base

      BASE_URL = 'https://finance.yahoo.com'

      def test(symbol)
        load_text(test_url(symbol))
      end

      def statistics(symbol)
        text = load_text(statistics_url(symbol))
        json = text.match(/root.App.main = ({.*});/i).captures.first
        JSON.parse(json)
      rescue
        nil
      end

      private

      def test_url(symbol)
        "#{BASE_URL}/quote/#{symbol}"
      end

      def statistics_url(symbol)
        "#{BASE_URL}/quote/#{symbol}/key-statistics?p=#{symbol}"
      end

    end
  end
end
