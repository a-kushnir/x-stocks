# frozen_string_literal: true

module XStocks
  class Stock
    # Stock AR Finders Business Model
    module ARFinders
      def find_all_random
        XStocks::AR::Stock.random.all.map { |ar_stock| XStocks::Stock.new(ar_stock) }
      end

      def find_all(*args)
        XStocks::AR::Stock.where(*args).all.map { |ar_stock| XStocks::Stock.new(ar_stock) }
      end

      def find_by(*args)
        ar_stock = XStocks::AR::Stock.find_by(*args)
        XStocks::Stock.new(ar_stock) if ar_stock
      end

      def find_by!(*args)
        ar_stock = XStocks::AR::Stock.find_by!(*args)
        XStocks::Stock.new(ar_stock)
      end

      def find_by_symbol(symbol)
        ar_stock = XStocks::AR::Stock.find_by(symbol: symbol.to_s.upcase)
        XStocks::Stock.new(ar_stock) if ar_stock
      end
    end
  end
end
