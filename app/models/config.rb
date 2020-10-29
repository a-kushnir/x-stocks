class Config < ApplicationRecord

  validates :key, presence: true, uniqueness: true
  serialize :value, JSON

  def self.[](key)
    Config.find_by(key: key)&.value
  end

  def self.[]=(key, value)
    config = Config.find_or_create_by(key: key)
    config.update(value: value)
  end

  def self.cached(key, expires_in)
    config = Config.find_by(key: key)

    if config.nil? || config.updated_at < expires_in.ago
      config ||= Config.new(key: key)
      config.value = yield
      config.save
    end

    config.value
  end

  def to_s
    key
  end

end
