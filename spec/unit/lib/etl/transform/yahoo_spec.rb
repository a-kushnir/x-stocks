# frozen_string_literal: true

require 'unit/spec_helper'
require 'etl/transform/yahoo'

describe Etl::Transform::Yahoo do
  subject(:transformer) { described_class.new(date: date) }

  let(:date) { OpenStruct.new(today: Date.new(2020, 1, 11)) }
  let(:stock) { mock_model(symbol: 'AAPL', company_name: nil, current_price: nil) }

  describe '#summary' do
    let(:stores) do
      {
        'StreamDataStore' => {
          'quoteData' => { 'AAPL' => { 'sharesOutstanding' => { 'raw' => 123.45 } } }
        },
        'QuoteSummaryStore' => {
          'price' => {
            'shortName' => 'Apple Inc.',
            'regularMarketPrice' => { 'raw' => 345.67 }
          },
          'summaryDetail' => { 'payoutRatio' => { 'raw' => 0.72 }, 'dividendRate' => { 'raw' => 4.33 } },
          'defaultKeyStatistics' => { 'beta' => { 'raw' => 0.34 } },
          'financialData' => {
            'recommendationMean' => { 'raw' => 1.77 },
            'targetHighPrice' => { 'raw' => 175 },
            'targetLowPrice' => { 'raw' => 83 },
            'targetMeanPrice' => { 'raw' => 151.75 },
            'targetMedianPrice' => { 'raw' => 157 }
          },
          'recommendationTrend' => { 'trend' => [
            { 'strongBuy' => 6, 'buy' => 3, 'hold' => 1, 'sell' => 0, 'strongSell' => 0 },
            { 'strongBuy' => 3, 'buy' => 3, 'hold' => 5, 'sell' => 4, 'strongSell' => 1 }
          ] },
          'summaryProfile' => { 'longBusinessSummary' => 'Apple Inc. designs, manufactures, and markets...' }
        },
        'ResearchPageStore' => {
          'technicalInsights' => { 'AAPL' => { 'instrumentInfo' => { 'valuation' => { 'discount' => '-21%' } } } }
        }
      }
    end

    let(:json) do
      { 'context' => { 'dispatcher' => { 'stores' => stores } } }
    end

    it 'stores data into model' do
      transformer.summary(stock, json)

      calls = {
        symbol: 'AAPL',
        company_name: 'Apple Inc.',
        current_price: 345.67,
        outstanding_shares: 123.45,
        payout_ratio: 72.0,
        yahoo_beta: 0.34,
        yahoo_rec: 1.77,
        yahoo_rec_details: { '2019-10-01' => [3, 3, 5, 4, 1], '2019-11-01' => [6, 3, 1, 0, 0] },
        est_annual_dividend: 4.33,
        yahoo_discount: -21,
        yahoo_fair_price: 273,
        yahoo_price_target: { high: 175, low: 83, mean: 151.75, median: 157 },
        description: 'Apple Inc. designs, manufactures, and markets...',
        save: []
      }

      expect(stock).to eq(calls)
    end
  end
end
