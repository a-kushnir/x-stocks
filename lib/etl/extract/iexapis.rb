# frozen_string_literal: true

module Etl
  module Extract
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

      def dividends(stock)
        data_loader.get_json(dividends_url(stock.symbol))
      end

      def dividends_1m(stock)
        data_loader.get_json(dividends_1m_url(stock.symbol))
      end

      def dividends_3m(stock)
        data_loader.get_json(dividends_3m_url(stock.symbol))
      end

      def dividends_6m(stock)
        data_loader.get_json(dividends_6m_url(stock.symbol))
      end

      def dividends_next(stock)
        data_loader.get_json(dividends_next_url(stock.symbol))
      end

      private

      def company_url(symbol)
        "#{BASE_URL}/stock/#{cgi.escape(symbol)}/company?token=#{token}"
      end

      def dividends_url(symbol)
        "#{BASE_URL}/stock/#{cgi.escape(symbol)}/dividends?token=#{token}"
      end

      def dividends_1m_url(symbol)
        "#{BASE_URL}/stock/#{cgi.escape(symbol)}/dividends/1m?token=#{token}"
      end

      def dividends_3m_url(symbol)
        "#{BASE_URL}/stock/#{cgi.escape(symbol)}/dividends/3m?token=#{token}"
      end

      def dividends_6m_url(symbol)
        "#{BASE_URL}/stock/#{cgi.escape(symbol)}/dividends/6m?token=#{token}"
      end

      def dividends_next_url(symbol)
        "#{BASE_URL}/stock/#{cgi.escape(symbol)}/dividends/next?token=#{token}"
      end

      attr_reader :data_loader, :token, :cgi
    end
  end
end
