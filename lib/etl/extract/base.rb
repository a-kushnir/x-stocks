module Etl
  module Extract
    class Base

      attr_reader :token
      attr_reader :logger

      def initialize(token: nil, logger: nil)
        @token = token
        @logger = logger
      end

      protected

      def get_text(url)
        response = Net::HTTP.get_response(URI(url))
        validate!(response, url)

        if response.is_a?(Net::HTTPSuccess)
          response.body
        end
      end

      def get_json(url)
        response = Net::HTTP.get_response(URI(url))
        validate!(response, url)

        if response.is_a?(Net::HTTPSuccess)
          JSON.parse(response.body)
        end
      end

      def post_json(url, body)
        uri = URI(url)
        request = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')

        request.body = body.to_json
        log_info("POST #{url}: #{body.to_json}")

        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          http.request(request)
        end
        validate!(response, url)

        if response.is_a?(Net::HTTPSuccess)
          JSON.parse(response.body)
        end
      end

      def esc(value)
        URI.escape(value)
      end

      def validate!(response, url)
        log_info("#{response.code} #{url}")
        log_info("(#{response.body.size} bytes): #{safe_limit(response.body, 512)}")
        raise '401 - Unauthorized' if response.code == '401'
        raise '429 - API limit reached' if response.code == '429' # Finnhub
        raise '500 - Internal Server Error' if response.code == '500'
      end

      def log_info(value)
        if logger
          logger.log_info(value)
        else
          puts value
        end
      end

      def safe_limit(value, limit)
        value = value.to_s
        value.size > limit ? "#{value[0..limit-1]}..." : value
      end

    end
  end
end
