module Etl
  module Refresh
    class Base

      def one_stock_with_message(stock)
        yield stock, "#{self.class.name.demodulize}: #{stock.symbol}"
      end

      def each_stock_with_message
        stocks = Stock.random.all.to_a
        stocks.each_with_index do |stock, index|
          yield stock, "#{self.class.name.demodulize}: #{stock.symbol} (#{index+1}/#{stocks.size})"
        end
      end

    end
  end
end
