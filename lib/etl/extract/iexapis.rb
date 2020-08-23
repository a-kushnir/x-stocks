module Etl
  module Extract
    class Iexapis < Base

      BASE_URL = 'https://cloud.iexapis.com/stable'

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

      def token
        value = ENV['IEXAPIS_KEY']
        raise 'ENV[IEXAPIS_KEY] is required to use this API' if value.blank?
        value
      end

      def company_url(symbol)
        "#{BASE_URL}/stock/#{esc(symbol)}/company?token=#{token}"
      end

      def dividends_url(symbol)
        "#{BASE_URL}/stock/#{esc(symbol)}/dividends?token=#{token}"
      end

      def dividends_3m_url(symbol)
        "#{BASE_URL}/stock/#{esc(symbol)}/dividends/3m?token=#{token}"
      end

      def dividends_6m_url(symbol)
        "#{BASE_URL}/stock/#{esc(symbol)}/dividends/6m?token=#{token}"
      end

      def dividends_next_url(symbol)
        "#{BASE_URL}/stock/#{esc(symbol)}/dividends/next?token=#{token}"
      end

    end
  end
end
