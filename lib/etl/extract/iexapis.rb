# frozen_string_literal: true

module Etl
  module Extract
    # Extracts data from cloud.iexapis.com
    class Iexapis
      BASE_URL = 'https://cloud.iexapis.com/stable'
      TOKEN_KEY = 'IEXAPIS_KEY'

      def initialize(data_loader, token, cgi: CGI)
        @data_loader = data_loader
        @token = token
        @cgi = cgi
      end

      def company(stock)
        data_loader.get_json(company_url(stock.symbol))
      end

      private

      def company_url(symbol)
        "#{BASE_URL}/stock/#{cgi.escape(symbol)}/company?token=#{token}"
      end

      attr_reader :data_loader, :token, :cgi
    end
  end
end
