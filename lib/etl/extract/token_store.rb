# frozen_string_literal: true

module Etl
  module Extract
    class TokenStore
      # Support for key_0, key_1, etc.
      SUFFIX_REGEX = /^_\d+$/.freeze
      PAUSE = 1.0

      attr_reader :key, :tokens

      def initialize(key, logger = nil, env: ENV)
        @logger = logger
        @key = key
        @env = env
      end

      def try_token
        load_tokens!

        success = false
        token = random_token!
        while token && !success
          begin
            result = yield token
            success = true
            result
          rescue Exception
            disable_token(token)
            token = random_token!
            sleep(PAUSE)
          end
        end
      end

      def random_token
        load_tokens!

        @tokens[rand(@tokens.size)] if @tokens.present?
      end

      def random_token!
        token = random_token
        raise 'All tokens are disabled' unless token

        token
      end

      def disable_token(token)
        load_tokens!

        result = @tokens.delete(token)
        log_info(result ? "TokenStore: #{token} disabled" : "TokenStore: #{token} not found")
        result
      end

      private

      def load_tokens!
        return @tokens if @tokens

        @tokens = []
        env.each do |k, v|
          next unless k.start_with?(@key)

          k = k[@key.size..]
          @tokens << v if k.blank? || k =~ SUFFIX_REGEX
        end

        log_info("TokenStore: loaded #{@tokens.size} keys for #{@key}")
        raise "ENV[#{@key}] is required to use this API" if @tokens.empty?

        @tokens
      end

      def log_info(value)
        logger&.log_info(value)
      end

      attr_reader :logger, :env
    end
  end
end
