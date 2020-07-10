class StocksTag < ApplicationRecord

  belongs_to :stock
  belongs_to :tag

  validates :stock, presence: true, uniqueness: { scope: :tag }
  validates :tag, presence: true

  def self.batch_update(stock, key, names)
    updated_ids = []
    (names || []).each do |tag|
      tag = ::Tag.find_or_create_by(key: key, name: tag)
      updated_ids << ::StocksTag.find_or_create_by(stock: stock, tag: tag).id
    end

    tag_ids = ::Tag.where(key: key).pluck(:id)
    ::StocksTag
        .where(stock_id: stock.id, tag_id: tag_ids)
        .where.not(id: updated_ids)
        .delete_all
  end

end
