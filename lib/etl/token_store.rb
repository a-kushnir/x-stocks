module Etl
  class TokenStore

    # Support for key_0, key_1, etc.
    SUFFIX_REGEX = /^_\d+$/

    attr_reader :logger
    attr_reader :key
    attr_reader :tokens

    def initialize(key, logger = nil)
      @logger = logger
      @key = key
      @tokens = load_tokens(key)
    end

    def try_token
      success = false
      token = random_token!
      while token && !success
        begin
          result = yield token
          success = true
          result
        rescue
          disable_token(token)
          token = random_token!
        end
      end
    end

    def random_token
      @tokens[rand(@tokens.size)] if @tokens.present?
    end

    def random_token!
      token = random_token
      raise 'All tokens are disabled' unless token
      token
    end

    def disable_token(token)
      log_info("TokenStore: #{token} disabled")
      @tokens.delete(token)
    end

    private

    def load_tokens(key)
      result = []
      ENV.each do |k, v|
        next unless k.start_with?(key)
        k = k[key.size..-1]
        result << v if k.blank? || k =~ SUFFIX_REGEX
      end
      log_info("TokenStore: loaded #{result.size} keys for #{key}")
      raise "ENV[#{key}] is required to use this API" if result.empty?
      result
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
