# frozen_string_literal: true

module XStocks
  # Exchange Business Model
  class Exchange
    def initialize(ar_exchange_class: XStocks::AR::Exchange)
      @ar_exchange_class = ar_exchange_class
    end

    def search_by(column, value)
      ar_exchange_class.all.detect do |exchange|
        exchange[column] && exchange[column]&.upcase == value&.upcase
      end
    end

    private

    attr_reader :ar_exchange_class
  end
end
