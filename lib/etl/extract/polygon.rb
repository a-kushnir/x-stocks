# frozen_string_literal: true

module Etl
  module Extract
    # Extracts data from polygon.io
    class Polygon
      BASE_URL = 'https://api.polygon.io'
      TOKEN_KEY = 'POLYGON_KEY'

      def initialize(data_loader, token, cgi: CGI)
        @data_loader = data_loader
        @token = token
        @cgi = cgi
      end

      def dividends(stock)
        data_loader.get_json(dividends_url(stock.symbol))
      end

      def next_page(json)
        return unless (url = next_url(json))

        data_loader.get_json(url)
      end

      private

      def dividends_url(symbol)
        "#{BASE_URL}/v3/reference/dividends?ticker=#{cgi.escape(symbol)}&apiKey=#{token}"
      end

      def next_url(json)
        return unless (url = json['next_url'].presence)

        "#{url}&apiKey=#{token}"
      end

      attr_reader :data_loader, :token, :cgi
    end
  end
end
