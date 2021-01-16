# frozen_string_literal: true

# Exchange Active Record Model
class Exchange < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :code, presence: true, uniqueness: true

  def self.search_by(column, value)
    Exchange.all.detect do |exchange|
      exchange[column] && exchange[column]&.upcase == value&.upcase
    end
  end

  def to_s
    "#{name} (#{code})"
  end
end
