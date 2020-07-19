module Etl
  module Extract
    class Iexapis < Base

      BASE_URL = 'https://cloud.iexapis.com/stable'
      IEXAPIS_KEY = ENV['IEXAPIS_KEY']

      def company(symbol)
        get_json(company_url(symbol))
      end

      def dividends(symbol)
        get_json(dividends_url(symbol))
      end

      def dividends_3m(symbol)
        get_json(dividends_3m_url(symbol))
      end

      def dividends_6m(symbol)
        get_json(dividends_6m_url(symbol))
      end

      def dividends_next(symbol)
        get_json(dividends_next_url(symbol))
      end

      private

      def company_url(symbol)
        "#{BASE_URL}/stock/#{esc(symbol)}/company?token=#{IEXAPIS_KEY}";
      end

      def dividends_url(symbol)
        "#{BASE_URL}/stock/#{esc(symbol)}/dividends?token=#{IEXAPIS_KEY}";
      end

      def dividends_3m_url(symbol)
        "#{BASE_URL}/stock/#{esc(symbol)}/dividends/3m?token=#{IEXAPIS_KEY}";
      end

      def dividends_6m_url(symbol)
        "#{BASE_URL}/stock/#{esc(symbol)}/dividends/6m?token=#{IEXAPIS_KEY}";
      end

      def dividends_next_url(symbol)
        "#{BASE_URL}/stock/#{esc(symbol)}/dividends/next?token=#{IEXAPIS_KEY}";
      end

    end
  end
end
