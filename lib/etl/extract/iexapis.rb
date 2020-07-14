module Etl
  module Extract
    class Iexapis < Base

      BASE_URL = 'https://cloud.iexapis.com/stable'
      IEXAPIS_KEY = ENV['IEXAPIS_KEY']

      def company(symbol)
        load_json(company_url(symbol))
      end

      def dividends(symbol)
        load_json(dividends_url(symbol))
      end

      def dividends_3m(symbol)
        load_json(dividends_3m_url(symbol))
      end

      def dividends_6m(symbol)
        load_json(dividends_6m_url(symbol))
      end

      def dividends_next(symbol)
        load_json(dividends_next_url(symbol))
      end

      private

      def company_url(symbol)
        "#{BASE_URL}/stock/#{symbol}/company?token=#{IEXAPIS_KEY}";
      end

      def dividends_url(symbol)
        "#{BASE_URL}/stock/#{symbol}/dividends?token=#{IEXAPIS_KEY}";
      end

      def dividends_3m_url(symbol)
        "#{BASE_URL}/stock/#{symbol}/dividends/3m?token=#{IEXAPIS_KEY}";
      end

      def dividends_6m_url(symbol)
        "#{BASE_URL}/stock/#{symbol}/dividends/6m?token=#{IEXAPIS_KEY}";
      end

      def dividends_next_url(symbol)
        "#{BASE_URL}/stock/#{symbol}/dividends/next?token=#{IEXAPIS_KEY}";
      end

    end
  end
end
