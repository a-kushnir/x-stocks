# frozen_string_literal: true

module Etl
  module Extract
    # Extracts data from finance.yahoo.com
    class Yahoo
      BASE_URL = 'https://finance.yahoo.com'

      DATA_REGEX = /root.App.main = ({.+});/i.freeze
      SYMBOL_REGEX = /"symbol":"([^"]+)"/.freeze

      def initialize(data_loader, cgi: CGI, json: JSON)
        @data_loader = data_loader
        @cgi = cgi
        @json = json
      end

      def summary(symbol)
        text = data_loader.get_text(summary_url(symbol), headers)
        data = text.match(DATA_REGEX).captures.first
        json.parse(data)
      end

      def stock_list_from_url(url)
        page = data_loader.get_text(url, headers)
        stock_list_from_page(page)
      end

      def stock_list_from_page(page)
        symbols = page.scan(SYMBOL_REGEX).map(&:first)
        symbols.uniq.sort
      end

      private

      def summary_url(symbol)
        "#{BASE_URL}/quote/#{cgi.escape(symbol)}?p=#{cgi.escape(symbol)}"
      end

      def headers
        {
          'user-agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.183 Safari/537.36'
        }
      end

      attr_reader :data_loader, :cgi, :json
    end
  end
end
