# frozen_string_literal: true

module Etl
  module Extract
    class Yahoo
      BASE_URL = 'https://finance.yahoo.com'

      def initialize(data_loader, uri: URI, json: JSON)
        @data_loader = data_loader
        @uri = uri
        @json = json
      end

      def summary(stock)
        text = data_loader.get_text(summary_url(stock.symbol), headers)
        data = text.match(/root.App.main = ({.*});/i).captures.first
        json.parse(data)
      end

      private

      def summary_url(symbol)
        "#{BASE_URL}/quote/#{uri.escape(symbol)}?p=#{uri.escape(symbol)}"
      end

      def headers
        {
          'user-agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.183 Safari/537.36'
        }
      end

      attr_reader :data_loader, :uri, :json
    end
  end
end
