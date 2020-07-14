module Etl
  module Transform
    class Yahoo

      def statistics(stock, json)
        summary = json&.dig('context', 'dispatcher', 'stores', 'QuoteSummaryStore')

        stock.payout_ratio = summary&.dig('summaryDetail', 'payoutRatio', 'raw') * 100 rescue nil
        stock.yahoo_beta = summary&.dig('defaultKeyStatistics', 'beta', 'raw')
        stock.yahoo_rec = summary&.dig('financialData', 'recommendationMean', 'raw')
        stock.est_annual_dividend = summary&.dig('summaryDetail', 'dividendRate', 'raw')

        stock.update_dividends!
      end

    end
  end
end
