# frozen_string_literal: true

module XStocks
  # Tag Business Model
  class Tag
    def initialize(ar_tag_class: XStocks::AR::Tag)
      @ar_tag_class = ar_tag_class
    end

    def batch_update(stock, key, names)
      updated_ids = []
      (names || []).each do |tag|
        updated_ids << ar_tag_class.find_or_create_by(key: key, name: tag, stock: stock).id
      end
      ar_tag_class.where(stock_id: stock.id, key: key).where.not(id: updated_ids).delete_all
    end

    private

    attr_reader :ar_tag_class
  end
end
