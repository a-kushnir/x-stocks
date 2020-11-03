module Etl
  module Extract
    class Yahoo < Base

      BASE_URL = 'https://finance.yahoo.com'

      def summary(symbol)
        text = get_text(summary_url(symbol))
        json = text.match(/root.App.main = ({.*});/i).captures.first
        JSON.parse(json)
      rescue
        nil
      end

      private

      def summary_url(symbol)
        "#{BASE_URL}/quote/#{esc(symbol)}?p=#{esc(symbol)}"
      end

    end
  end
end
