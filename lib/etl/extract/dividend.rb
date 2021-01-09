# frozen_string_literal: true

module Etl
  module Extract
    class Dividend < Base
      BASE_URL = 'https://www.dividend.com/api'

      def data(stock)
        symbol = "#{stock.symbol}--#{stock.exchange.dividend_code}"

        body = {
            'tm' => '3-comparison-center',
            'r' => "ES::DividendStock::Stock##{symbol}",
            'default_tab' => 'best-dividend-stocks',
            'only' => %w[meta data thead],
            'selected_symbols' => [symbol]
        }

        post_json(data_url, body)
      end

      private

      def data_url
        "#{BASE_URL}/data_set/"
      end
    end
  end
end
