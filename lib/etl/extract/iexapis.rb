module Etl
  module Extract
    class Iexapis < Base

      BASE_URL = 'https://cloud.iexapis.com/stable'
      IEXAPIS_KEY = ENV['IEXAPIS_KEY']

      def company(symbol)
        load_json(company_url(symbol))
      end

      def dividends_5y(symbol)
        load_json(dividends_5y_url(symbol))
      end

      def dividends_next(symbol)
        load_json(dividends_next_url(symbol))
      end

      private

      def company_url(symbol)
        "#{BASE_URL}/stock/#{symbol}/company?token=#{IEXAPIS_KEY}";
      end

      def dividends_5y_url(symbol)
        "#{BASE_URL}/stock/#{symbol}/dividends/5y?token=#{IEXAPIS_KEY}";
      end

      def dividends_next_url(symbol)
        "#{BASE_URL}/stock/#{symbol}/dividends/next?token=#{IEXAPIS_KEY}";
      end

    end
  end
end
