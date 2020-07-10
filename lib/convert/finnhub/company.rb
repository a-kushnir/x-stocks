module Convert
  module Finnhub
    class Company

      def process(stock, json)
        stock.ipo = json['ipo']
        stock.logo = json['logo']
        stock.save
      end

    end
  end
end
