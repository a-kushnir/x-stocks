class Exchange < ApplicationRecord

  validates :name, presence: true, uniqueness: true
  validates :short_name, presence: true, uniqueness: true

  def to_s
    "#{name} (#{short_name})"
  end

end
