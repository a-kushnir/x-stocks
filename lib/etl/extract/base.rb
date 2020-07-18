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

        logger&.log_info("#{response.code} #{url}")
        logger&.log_info("#{response.body}")
        raise 'API limit reached' if response.code == 429

        if response.is_a?(Net::HTTPSuccess)
          response.body
        end
      end

      def load_json(url)
        response = Net::HTTP.get_response(URI(url))

        logger&.log_info("#{response.code} #{url}")
        logger&.log_info("#{response.body}")
        raise 'API limit reached' if response.code == 429

        if response.is_a?(Net::HTTPSuccess)
          JSON.parse(response.body)
        end
      end

      def esc(value)
        URI.escape(value)
      end

    end
  end
end
