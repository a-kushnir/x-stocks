# frozen_string_literal: true

module XStocks
  # Config Business Model
  class Config
    def initialize(config_ar_class: XStocks::AR::Config)
      @config_ar_class = config_ar_class
    end

    def [](key)
      config_ar_class.find_by(key: key)&.value
    end

    def []=(key, value)
      config = config_ar_class.find_or_create_by(key: key)
      config.update(value: value)
    end

    def cached(key, expires_in)
      config = config_ar_class.find_by(key: key)

      if config.nil? || expires_in.nil? || config.updated_at < expires_in.ago
        config ||= config_ar_class.new(key: key)
        config.value = yield
        config.save
      end

      config.value
    end

    private

    attr_reader :config_ar_class
  end
end
