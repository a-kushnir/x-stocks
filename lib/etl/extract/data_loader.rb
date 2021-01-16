# frozen_string_literal: true

module Etl
  module Extract
    # Loads data in different formats using http and https protocols
    class DataLoader
      attr_reader :logger

      def initialize(logger)
        @logger = logger
      end

      def download(path, url)
        response = http_get(url)
        validate!(response, url)
        return unless response.is_a?(Net::HTTPSuccess)

        File.open(path, 'wb') { |file| file << response.body }
      end

      def http_get(url, headers = {})
        uri = URI(url)
        request = Net::HTTP::Get.new(uri)
        headers.each { |key, value| request[key] = value }
        http = Net::HTTP.new(uri.hostname, uri.port)
        http.use_ssl = uri.scheme == 'https'
        http.request(request)
      end

      def get_text(url, headers = {})
        response = http_get(url, headers)
        validate!(response, url)
        return unless response.is_a?(Net::HTTPSuccess)

        response.body
      end

      def get_json(url, headers = {})
        response = http_get(url, headers)
        validate!(response, url)
        return unless response.is_a?(Net::HTTPSuccess)

        JSON.parse(response.body)
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
        return unless response.is_a?(Net::HTTPSuccess)

        JSON.parse(response.body)
      end

      def validate!(response, url)
        log_info("#{response.code} #{url}")
        log_info("(#{response.body.size} bytes): #{response.body}")
        raise "#{response.code} - #{response.body}" if response.code != '200'
      end

      def log_info(value)
        if logger
          logger.log_info(value)
        else
          puts value
        end
      end
    end
  end
end
