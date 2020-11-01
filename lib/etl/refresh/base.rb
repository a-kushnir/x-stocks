module Etl
  module Refresh
    class Base

      def one_stock_with_message(stock)
        yield stock, {
            message: self.class.name.demodulize,
            percent: 0
        }
      end

      def each_stock_with_message
        stocks = Stock.random.all.to_a
        stocks.each_with_index do |stock, index|
          yield stock, {
              message: "Processing #{stock.symbol}",
              percent: index * 100 / stocks.length
          }
        end
      end

      def completed_message
        {
          message: "Completed",
          percent: 100
        }
      end

    end
  end
end
