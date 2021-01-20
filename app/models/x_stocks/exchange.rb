# frozen_string_literal: true

module XStocks
  # Exchange Business Model
  class Exchange
    def initialize(exchange_ar_class: XStocks::AR::Exchange)
      @exchange_ar_class = exchange_ar_class
    end

    def search_by(column, value)
      exchange_ar_class.all.detect do |exchange|
        exchange[column] && exchange[column]&.upcase == value&.upcase
      end
    end

    private

    attr_reader :exchange_ar_class
  end
end
