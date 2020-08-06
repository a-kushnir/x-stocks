class Exchange < ApplicationRecord

  validates :name, presence: true, uniqueness: true
  validates :short_name, presence: true, uniqueness: true

  def to_s
    "#{name} (#{short_name})"
  end

  def self.search(name)
    name = name.to_s
    all.detect do |exchange|
      exchange.name.downcase == name.downcase ||
      exchange.short_name.downcase == name.downcase
    end
  end

  def code
    if short_name.downcase == 'amex'
      'nysearca'
    else
      short_name.downcase
    end
  end

end
