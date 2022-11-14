# frozen_string_literal: true

module Etl
  module Extract
    # Extracts data from finnhub.io
    class Finnhub
      BASE_URL = 'https://finnhub.io/api/v1'
      TOKEN_KEY = 'FINNHUB_KEY'

      def initialize(data_loader, token, cgi: CGI)
        @data_loader = data_loader
        @token = token
        @cgi = cgi
      end

      def company(stock)
        json = data_loader.get_json(company_url(stock.symbol))
        download_logo(json)
        json
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

      def candle(stock, from, to, resolution)
        data_loader.get_json(candle_url(stock.symbol, from, to, resolution))
      end

      def tech_indicator(stock, resolution)
        data_loader.get_json(tech_indicator_url(stock.symbol, resolution))
      end

      def indicator(stock, resolution:, from:, to:, indicator:, **options)
        options = options.merge(resolution: resolution, from: from, to: to, indicator: indicator)
        data_loader.get_json(indicator_url(stock.symbol, options))
      end

      private

      def download_logo(json)
        logo_url = json['logo']
        json['logo'] = data_loader.get_redirect(json['logo']) if logo_url.present?
      end

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
        "#{BASE_URL}/calendar/earnings?from=#{from.to_fs(:db)}&to=#{to.to_fs(:db)}&token=#{token}"
      end

      def candle_url(symbol, from, to, resolution)
        "#{BASE_URL}/stock/candle?symbol=#{cgi.escape(symbol)}&resolution=#{resolution}&from=#{from.to_time.to_i}&to=#{to.to_time.to_i}&token=#{token}"
      end

      def tech_indicator_url(symbol, resolution)
        "#{BASE_URL}/scan/technical-indicator?symbol=#{cgi.escape(symbol)}&resolution=#{resolution}&token=#{token}"
      end

      def indicator_url(symbol, options)
        "#{BASE_URL}/indicator?symbol=#{cgi.escape(symbol)}&#{options.to_query}&token=#{token}"
      end

      attr_reader :data_loader, :token, :cgi
    end
  end
end
