module Convert
  module Finnhub
    class Company

      def process(stock, json)
        append_company(stock, json) if json
      end

      private

      def append_company(stock, json)
        company = stock.company || ::Company.new(stock: stock)

        company.ipo = json['ipo']
        company.logo = json['logo']
        company.save
      end

    end
  end
end
