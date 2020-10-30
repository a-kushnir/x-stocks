module Etl
  module Extract
    class Finnhub < Base

      BASE_URL = 'https://finnhub.io/api/v1'
      TOKEN_KEY = 'FINNHUB_KEY'

      def company(symbol)
        get_json(company_url(symbol))
      end

      def peers(symbol)
        get_json(peers_url(symbol))
      end

      def quote(symbol)
        get_json(quote_url(symbol))
      end

      def recommendation(symbol)
        get_json(recommendation_url(symbol))
      end

      def price_target(symbol)
        get_json(price_target_url(symbol))
      end

      def earnings(symbol)
        get_json(earnings_url(symbol))
      end

      def metric(symbol)
        get_json(metric_url(symbol))
      end

      def earnings_calendar(from, to)
        get_json(earnings_calendar_url(from, to))
      end

      private

      def company_url(symbol)
        "#{BASE_URL}/stock/profile2?symbol=#{esc(symbol)}&token=#{token}"
      end

      def peers_url(symbol)
        "#{BASE_URL}/stock/peers?symbol=#{esc(symbol)}&token=#{token}"
      end

      def quote_url(symbol)
        "#{BASE_URL}/quote?symbol=#{esc(symbol)}&token=#{token}"
      end

      def recommendation_url(symbol)
        "#{BASE_URL}/stock/recommendation?symbol=#{esc(symbol)}&token=#{token}"
      end

      def price_target_url(symbol)
        "#{BASE_URL}/stock/price-target?symbol=#{esc(symbol)}&token=#{token}"
      end

      def earnings_url(symbol)
        "#{BASE_URL}/stock/earnings?symbol=#{esc(symbol)}&token=#{token}"
      end

      def metric_url(symbol)
        "#{BASE_URL}/stock/metric?symbol=#{esc(symbol)}&metric=all&token=#{token}"
      end

      def earnings_calendar_url(from, to)
        "#{BASE_URL}/calendar/earnings?from=#{from.to_s(:db)}&to=#{to.to_s(:db)}&token=#{token}"
      end

    end
  end
end
