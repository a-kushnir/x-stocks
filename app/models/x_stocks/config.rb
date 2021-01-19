# frozen_string_literal: true

module XStocks
  # Config Business Model
  class Config
    def initialize(ar_config_class: XStocks::AR::Config)
      @ar_config_class = ar_config_class
    end

    def [](key)
      ar_config_class.find_by(key: key)&.value
    end

    def []=(key, value)
      config = ar_config_class.find_or_create_by(key: key)
      config.update(value: value)
    end

    def cached(key, expires_in)
      config = ar_config_class.find_by(key: key)

      if config.nil? || expires_in.nil? || config.updated_at < expires_in.ago
        config ||= ar_config_class.new(key: key)
        config.value = yield
        config.save
      end

      config.value
    end

    def to_s
      key
    end

    private

    attr_reader :ar_config_class
  end
end
