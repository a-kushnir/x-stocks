# frozen_string_literal: true

require 'unit/spec_helper'
require 'etl/transform/finnhub'

describe Etl::Transform::Finnhub do
  subject(:transformer) { described_class.new(exchange_class: exchange_class, stock_class: stock_class, stock_ar_class: stock_ar_class) }

  let(:exchange_class) { nil }
  let(:stock_class) { OpenStruct.new(new: mock_model) }
  let(:stock_ar_class) { nil }
  let(:stock) { mock_model }

  describe '#company' do
    let(:exchange_class) do
      exchange = OpenStruct.new(search_by: nil)
      allow(exchange).to receive(:search_by).with(:finnhub_code, 'NYSE').and_return('NYSE_EXCHANGE')
      OpenStruct.new(new: exchange)
    end

    let(:stock) { mock_model(exchange: nil) }

    let(:json) do
      {
        'ipo' => '1980-01-01',
        'logo' => 'https://static.finnhub.io/logo/url_to_a_logo.png',
        'exchange' => 'NYSE',
        'finnhubIndustry' => 'Technology'
      }
    end

    it 'saves data into model' do
      transformer.company(stock, json)

      calls = {
        ipo: '1980-01-01',
        logo: 'https://static.finnhub.io/logo/url_to_a_logo.png',
        exchange: 'NYSE_EXCHANGE',
        sector: 'Technology'
      }

      expect(stock).to eq(calls)
    end

    it 'searches exchange by finnhub_code' do
      transformer.company(stock, json)
      expect(exchange_class.new).to have_received(:search_by).with(:finnhub_code, 'NYSE')
    end
  end

  describe '#peers' do
    let(:json) { %w[PEER1 PEER2] }

    it 'saves data into model' do
      transformer.peers(stock, json)

      calls = {
        peers: %w[PEER1 PEER2]
      }

      expect(stock).to eq(calls)
    end
  end

  describe '#quote' do
    let(:json) do
      {
        'c' => 100.11,
        'h' => 100.22,
        'l' => 100.33,
        'o' => 100.44,
        'pc' => 100.55
      }
    end

    it 'saves data into model' do
      transformer.quote(stock, json)

      calls = {
        current_price: 100.11,
        prev_close_price: 100.55,
        open_price: 100.44,
        day_low_price: 100.33,
        day_high_price: 100.22
      }

      expect(stock).to eq(calls)
    end

    describe '#recommendation' do
      let(:json) do
        [
          {
            'buy' => 24,
            'hold' => 7,
            'period' => '2020-03-01',
            'sell' => 0,
            'strongBuy' => 13,
            'strongSell' => 0
          },
          {
            'buy' => 17,
            'hold' => 13,
            'period' => '2020-02-01',
            'sell' => 5,
            'strongBuy' => 13,
            'strongSell' => 0
          }
        ]
      end

      it 'saves data into model' do
        transformer.recommendation(stock, json)

        calls = {
          finnhub_rec: 2.04,
          finnhub_rec_details: {
            Date.new(2020, 2, 1) => [13, 17, 13, 5, 0],
            Date.new(2020, 3, 1) => [13, 24, 7, 0, 0]
          }
        }

        expect(stock).to eq(calls)
      end
    end

    describe '#price_target' do
      let(:json) do
        {
          'targetHigh' => 500,
          'targetLow' => 166,
          'targetMean' => 387.03,
          'targetMedian' => 417.5
        }
      end

      it 'saves data into model' do
        transformer.price_target(stock, json)

        calls = {
          finnhub_price_target: { high: 500, low: 166, mean: 387.03, median: 417.5 }
        }

        expect(stock).to eq(calls)
      end
    end

    describe '#earnings' do
      let(:json) do
        [
          {
            'actual' => 2.56,
            'estimate' => 2.38,
            'period' => '2019-03-31',
            'symbol' => 'AAPL'
          },
          {
            'actual' => 4.21,
            'estimate' => 4.15,
            'period' => '2018-12-31',
            'symbol' => 'AAPL'
          }
        ]
      end

      it 'saves data into model' do
        transformer.earnings(stock, json)

        calls = {
          earnings: [
            { 'actual' => 2.56, 'estimate' => 2.38, 'period' => '2019-03-31' },
            { 'actual' => 4.21, 'estimate' => 4.15, 'period' => '2018-12-31' }
          ]
        }

        expect(stock).to eq(calls)
      end
    end

    describe '#metric' do
      let(:json) do
        {
          'metric' => {
            '10DayAverageTradingVolume' => 32.50147,
            '52WeekHigh' => 310.43,
            '52WeekHighDate' => '2020-12-29',
            '52WeekLow' => 149.22,
            '52WeekLowDate' => '2019-01-14',
            '52WeekPriceReturnDaily' => 101.96334,
            'beta' => 1.2989,
            'dividendGrowthRate5Y' => 9.83445,
            'epsGrowth3Y' => 12.47869,
            'epsGrowth5Y' => 7.28691,
            'epsInclExtraItemsTTM' => 3.26679
          }
        }
      end

      it 'saves data into model' do
        transformer.metric(stock, json)

        calls = {
          finnhub_beta: 1.2989,
          week_52_high: 310.43,
          week_52_high_date: '2020-12-29',
          week_52_low: 149.22,
          week_52_low_date: '2019-01-14',
          dividend_growth_5y: 9.83445,
          eps_growth_3y: 12.47869,
          eps_growth_5y: 7.28691,
          eps_ttm: 3.26679
        }

        expect(stock).to eq(calls)
      end
    end

    describe '#earnings_calendar' do
      let(:stock) { mock_model(symbol: 'AAPL', next_earnings_date: nil) }

      let(:json) do
        {
          'earningsCalendar' => [
            {
              'date' => '2019-01-28',
              'epsActual' => 4.99,
              'epsEstimate' => 4.5474,
              'hour' => 'amc',
              'quarter' => 1,
              'revenueActual' => 91_819_000_000,
              'revenueEstimate' => 88_496_400_810,
              'symbol' => 'AAPL',
              'year' => 2019
            },
            {
              'date' => '2018-10-30',
              'epsActual' => 3.03,
              'epsEstimate' => 2.8393,
              'hour' => 'amc',
              'quarter' => 4,
              'revenueActual' => 64_040_000_000,
              'revenueEstimate' => 62_985_161_760,
              'symbol' => 'AAPL',
              'year' => 2018
            }
          ]
        }
      end

      it 'saves data into model' do
        transformer.earnings_calendar(json, stock)

        calls = {
          symbol: 'AAPL',
          next_earnings_date: Date.new(2019, 1, 28),
          next_earnings_hour: 'amc',
          next_earnings_est_eps: 4.5474,
          next_earnings_details: [
            {
              date: '2019-01-28',
              hour: 'amc',
              eps_estimate: 4.5474,
              eps_actual: 4.99,
              revenue_estimate: 88_496_400_810,
              revenue_actual: 91_819_000_000,
              quarter: 1,
              year: 2019
            },
            {
              date: '2018-10-30',
              hour: 'amc',
              eps_estimate: 2.8393,
              eps_actual: 3.03,
              revenue_estimate: 62_985_161_760,
              revenue_actual: 64_040_000_000,
              quarter: 4,
              year: 2018
            }
          ],
          save: []
        }

        expect(stock).to eq(calls)
      end
    end
  end
end
