module Etl
  module Extract
    class Yahoo < Base

      BASE_URL = 'https://finance.yahoo.com'

      def test(symbol)
        get_text(test_url(symbol))
      end

      def statistics(symbol)
        text = get_text(statistics_url(symbol))
        json = text.match(/root.App.main = ({.*});/i).captures.first
        JSON.parse(json)
      rescue
        nil
      end

      private

      def test_url(symbol)
        "#{BASE_URL}/quote/#{esc(symbol)}"
      end

      def statistics_url(symbol)
        "#{BASE_URL}/quote/#{esc(symbol)}/key-statistics?p=#{esc(symbol)}"
      end

    end
  end
end
