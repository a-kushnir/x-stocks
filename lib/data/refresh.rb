class Data
  class Refresh

    def company_data?(stock)
      return true if stock.saved_change_to_symbol?
      return false unless stock.saved_change_to_updated_at?
      prev_updated_at = stock.saved_change_to_updated_at.first
      prev_updated_at.nil? || prev_updated_at < 7.days.ago
    end

    def company_data!(stock)
      json = Import::Iexapis.new.company(stock.symbol)
      Convert::Iexapis::Company.new.process(stock, json)

      json = Import::Finnhub.new.company(stock.symbol)
      Convert::Finnhub::Company.new.process(stock, json)

      json = Import::Finnhub.new.peers(stock.symbol)
      Convert::Finnhub::Peers.new.process(stock, json)

      financial_data!(stock)
    end

    def company_data(stock)
      company_data!(stock) if company_data?(stock)
    end

    def financial_data!(stock)
      json = Import::Finnhub.new.quote(stock.symbol)
      Convert::Finnhub::Quote.new.process(stock, json)
    end

    def all_financial_data?
      StockQuote.where('updated_at < ?', 1.hour.ago).exists?
    end

    def all_financial_data!
      Stock.all.each do |stock|
        financial_data!(stock)
        sleep(1.0/30) # Limit up to 30 requests per second
      end
    end

    def all_financial_data_updated_at
      StockQuote.limit(1).pluck(:updated_at).first
    end

  end
end
