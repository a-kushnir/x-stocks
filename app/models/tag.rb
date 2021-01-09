# frozen_string_literal: true

class Tag < ApplicationRecord
  belongs_to :stock

  validates :key, presence: true
  validates :name, presence: true, uniqueness: { scope: %i[key stock] }

  default_scope { order(name: :asc) }

  def to_s
    name
  end

  def self.batch_update(stock, key, names)
    updated_ids = []
    (names || []).each do |tag|
      updated_ids << ::Tag.find_or_create_by(key: key, name: tag, stock: stock).id
    end
    ::Tag.where(stock_id: stock.id, key: key).where.not(id: updated_ids).delete_all
  end
end
