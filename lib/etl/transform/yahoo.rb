module Etl
  module Transform
    class Yahoo

      def statistics(stock, json)
        summary = json&.dig('context', 'dispatcher', 'stores')

        stock.outstanding_shares = summary&.dig('StreamDataStore', 'quoteData', stock.symbol, 'sharesOutstanding', 'raw')
        stock.payout_ratio = summary&.dig('QuoteSummaryStore', 'summaryDetail', 'payoutRatio', 'raw') * 100 rescue nil
        stock.yahoo_beta = summary&.dig('QuoteSummaryStore', 'defaultKeyStatistics', 'beta', 'raw')
        stock.yahoo_rec = summary&.dig('QuoteSummaryStore', 'financialData', 'recommendationMean', 'raw')
        stock.est_annual_dividend = summary&.dig('QuoteSummaryStore', 'summaryDetail', 'dividendRate', 'raw')

        stock.update_dividends!
      end

    end
  end
end
