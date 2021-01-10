# frozen_string_literal: true

module Etl
  module Extract
    class Dividend
      BASE_URL = 'https://www.dividend.com/api'

      def initialize(data_loader, uri: URI)
        @data_loader = data_loader
        @uri = uri
      end

      def data(stock)
        symbol = uri.escape("#{stock.symbol}--#{stock.exchange.dividend_code}")

        body = {
          'tm' => '3-comparison-center',
          'r' => "ES::DividendStock::Stock##{symbol}",
          'default_tab' => 'best-dividend-stocks',
          'only' => %w[meta data thead],
          'selected_symbols' => [symbol]
        }

        data_loader.post_json(data_url, body)
      end

      private

      def data_url
        "#{BASE_URL}/data_set/"
      end

      attr_reader :data_loader, :uri
    end
  end
end
