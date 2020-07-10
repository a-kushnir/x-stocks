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

  def to_s
    key
  end

end
