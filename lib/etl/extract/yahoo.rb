module Etl
  module Extract
    class Yahoo < Base

      BASE_URL = 'https://finance.yahoo.com'

      def summary(symbol)
        text = get_text(summary_url(symbol), headers)
        json = text.match(/root.App.main = ({.*});/i).captures.first
        JSON.parse(json)
      rescue
        nil
      end

      private

      def summary_url(symbol)
        "#{BASE_URL}/quote/#{esc(symbol)}?p=#{esc(symbol)}"
      end

      def headers
        {
          'user-agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.183 Safari/537.36'
        }
      end

    end
  end
end
