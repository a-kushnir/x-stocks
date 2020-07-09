module Convert
  module Iexapis
    class Dividend

      def process(stock, json)
        if json.present?
          (json || []).each do |row|
            ex_date = Date.parse(row['exDate'])
            div = stock.stock_dividends.detect {|d| d.ex_date == ex_date }
            div ||= ::StockDividend.new(stock: stock, ex_date: ex_date)
            div.payment_date = row['paymentDate']
            div.record_date = row['recordDate']
            div.declared_date = row['declaredDate']
            div.amount = row['amount']
            div.flag = row['flag']
            div.currency = row['currency']
            div.description = row['description']
            div.frequency = row['frequency']
            div.save
          end
        end
      end

    end
  end
end
