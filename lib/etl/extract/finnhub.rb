# frozen_string_literal: true

module Etl
  module Extract
    class Finnhub
      BASE_URL = 'https://finnhub.io/api/v1'
      TOKEN_KEY = 'FINNHUB_KEY'

      def initialize(data_loader, token, cgi: CGI)
        @data_loader = data_loader
        @token = token
        @cgi = cgi
      end

      def company(stock)
        data_loader.get_json(company_url(stock.symbol))
      end

      def peers(stock)
        data_loader.get_json(peers_url(stock.symbol))
      end

      def quote(stock)
        data_loader.get_json(quote_url(stock.symbol))
      end

      def recommendation(stock)
        data_loader.get_json(recommendation_url(stock.symbol))
      end

      def price_target(stock)
        data_loader.get_json(price_target_url(stock.symbol))
      end

      def earnings(stock)
        data_loader.get_json(earnings_url(stock.symbol))
      end

      def metric(stock)
        data_loader.get_json(metric_url(stock.symbol))
      end

      def earnings_calendar(from, to)
        data_loader.get_json(earnings_calendar_url(from, to))
      end

      private

      def company_url(symbol)
        "#{BASE_URL}/stock/profile2?symbol=#{cgi.escape(symbol)}&token=#{token}"
      end

      def peers_url(symbol)
        "#{BASE_URL}/stock/peers?symbol=#{cgi.escape(symbol)}&token=#{token}"
      end

      def quote_url(symbol)
        "#{BASE_URL}/quote?symbol=#{cgi.escape(symbol)}&token=#{token}"
      end

      def recommendation_url(symbol)
        "#{BASE_URL}/stock/recommendation?symbol=#{cgi.escape(symbol)}&token=#{token}"
      end

      def price_target_url(symbol)
        "#{BASE_URL}/stock/price-target?symbol=#{cgi.escape(symbol)}&token=#{token}"
      end

      def earnings_url(symbol)
        "#{BASE_URL}/stock/earnings?symbol=#{cgi.escape(symbol)}&token=#{token}"
      end

      def metric_url(symbol)
        "#{BASE_URL}/stock/metric?symbol=#{cgi.escape(symbol)}&metric=all&token=#{token}"
      end

      def earnings_calendar_url(from, to)
        "#{BASE_URL}/calendar/earnings?from=#{from.to_s(:db)}&to=#{to.to_s(:db)}&token=#{token}"
      end

      attr_reader :data_loader, :token, :cgi
    end
  end
end
