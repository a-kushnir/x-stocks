module Etl
  module Extract
    class Base

      attr_reader :logger

      def initialize(logger)
        @logger = logger
      end

      protected

      def load_text(url)
        response = Net::HTTP.get_response(URI(url))
        validate!(response, url)

        if response.is_a?(Net::HTTPSuccess)
          response.body
        end
      end

      def load_json(url)
        response = Net::HTTP.get_response(URI(url))
        validate!(response, url)

        if response.is_a?(Net::HTTPSuccess)
          JSON.parse(response.body)
        end
      end

      def esc(value)
        URI.escape(value)
      end

      def validate!(response, url)
        logger&.log_info("#{response.code} #{url}")
        logger&.log_info("#{response.body}")
        raise '401 - Unauthorized' if response.code == 401
        raise '429 - API limit reached' if response.code == 429 # Finnhub
        raise '500 - Internal Server Error' if response.code == 500
      end

    end
  end
end
