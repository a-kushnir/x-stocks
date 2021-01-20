# frozen_string_literal: true

module XStocks
  # Tag Business Model
  class Tag
    def initialize(tag_ar_class: XStocks::AR::Tag)
      @tag_ar_class = tag_ar_class
    end

    def batch_update(stock, key, names)
      updated_ids = []
      (names || []).each do |tag|
        updated_ids << tag_ar_class.find_or_create_by(key: key, name: tag, stock: stock).id
      end
      tag_ar_class.where(stock_id: stock.id, key: key).where.not(id: updated_ids).delete_all
    end

    private

    attr_reader :tag_ar_class
  end
end
