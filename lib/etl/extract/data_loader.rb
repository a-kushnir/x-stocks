# frozen_string_literal: true

require 'net/http'

module Etl
  module Extract
    # Loads data in different formats using http and https protocols
    class DataLoader
      attr_reader :logger

      TEXT_CONTENT_TYPES = %w[application/json text/html].freeze

      DEFAULT_HEADERS = {
        'user-agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.67 Safari/537.36'
      }.freeze

      def initialize(logger = nil)
        @logger = logger
      end

      def download(url, path = nil)
        response = fetch(url)
        validate!(response, url)
        return unless response.is_a?(Net::HTTPSuccess)

        if path
          File.open(path, 'wb') { |file| file << response.body } unless response.body.size.zero?
        else
          response.body
        end
      end

      def http_get(url, headers = DEFAULT_HEADERS)
        uri = URI(url)
        request = Net::HTTP::Get.new(uri)
        headers.each { |key, value| request[key] = value }
        http = Net::HTTP.new(uri.hostname, uri.port)
        http.use_ssl = uri.scheme == 'https'
        http.request(request)
      end

      def fetch(url, headers = DEFAULT_HEADERS, limit: 10)
        raise 'Too Many Redirects' if limit.zero?

        response = http_get(url, headers)
        if response.is_a?(Net::HTTPRedirection)
          fetch(response['location'], headers, limit: limit - 1)
        else
          response
        end
      end

      def get_redirect(url, headers = DEFAULT_HEADERS)
        response = http_get(url, headers)
        response['location'] if response.is_a?(Net::HTTPRedirection)
      end

      def get_text(url, headers = DEFAULT_HEADERS)
        response = http_get(url, headers)
        validate!(response, url)
        return unless response.is_a?(Net::HTTPSuccess)

        response.body
      end

      def get_json(url, headers = DEFAULT_HEADERS)
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
        is_text = TEXT_CONTENT_TYPES.include?(response.content_type)
        log_info("(#{response.content_type}, #{response.body.size} bytes): #{is_text ? response.body : '<binary>'}")
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
