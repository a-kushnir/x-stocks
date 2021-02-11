# frozen_string_literal: true

module Etl
  module Transform
    # Transforms data extracted from finnhub.io
    class Finnhub
      def initialize(exchange_class: XStocks::Exchange,
                     stock_class: XStocks::Stock,
                     stock_ar_class: XStocks::AR::Stock)
        @exchange_class = exchange_class
        @stock_class = stock_class
        @stock_ar_class = stock_ar_class
      end

      def company(stock, json)
        stock.sector ||= 'N/A'

        if json.present?
          stock.ipo = json['ipo']
          stock.logo = json['logo']
          stock.exchange ||= exchange_class.new.search_by(:finnhub_code, json['exchange']) if json['exchange'].present?
          stock.sector = json['finnhubIndustry'].presence || 'N/A'
        end

        stock_class.new.save(stock)
      end

      def peers(stock, json)
        return if json.blank?

        stock.peers = json

        stock_class.new.save(stock)
      end

      def quote(stock, json)
        return if json.blank?

        stock.current_price = json['c']
        stock.prev_close_price = json['pc']
        stock.open_price = json['o']
        stock.day_low_price = json['l']
        stock.day_high_price = json['h']

        stock_class.new.save(stock)
      end

      def recommendation(stock, json)
        json ||= []

        json.sort_by! { |row| Date.parse(row['period']) }
        json = json[-4..] if json.size > 4

        hash = {}
        json.each do |row|
          hash[Date.parse(row['period'])] = [
            row['strongBuy'],
            row['buy'],
            row['hold'],
            row['sell'],
            row['strongSell']
          ]
        end

        stock.finnhub_rec_details = hash
        stock.finnhub_rec = recommendation_mean(hash)

        stock_class.new.save(stock)
      end

      def price_target(stock, json)
        stock.finnhub_price_target =
          if json.present? &&
             (json['targetHigh']).positive? && (json['targetLow']).positive? &&
             (json['targetMean']).positive? && (json['targetMedian']).positive?
            {
              high: json['targetHigh'],
              low: json['targetLow'],
              mean: json['targetMean'],
              median: json['targetMedian']
            }
          end

        stock_class.new.save(stock)
      end

      def earnings(stock, json)
        stock.earnings =
          if json.present?
            json.map do |row|
              row.delete('symbol')
              row['estimate'] = row['estimate'].round(4) if row['estimate']
              row
            end
          end

        stock_class.new.save(stock)
      end

      def metric(stock, json)
        json ||= {}
        data = json['metric'] || {}
        stock.finnhub_beta = data['beta']
        stock.week_52_high = data['52WeekHigh']
        stock.week_52_high_date = data['52WeekHighDate']
        stock.week_52_low = data['52WeekLow']
        stock.week_52_low_date = data['52WeekLowDate']
        stock.dividend_growth_5y = data['dividendGrowthRate5Y']
        stock.eps_growth_3y = data['epsGrowth3Y']
        stock.eps_growth_5y = data['epsGrowth5Y']
        stock.eps_ttm = data['epsInclExtraItemsTTM']
      end

      def earnings_calendar(json, stock = nil)
        json ||= []
        (json['earningsCalendar'] || []).each do |row|
          next if stock && stock.symbol != row['symbol']

          s = stock
          s ||= stock_ar_class.find_by(symbol: row['symbol'])
          next unless s

          date = Date.parse(row['date'])
          if s.next_earnings_date.nil? ||
             (date.future? && s.next_earnings_date >= date)
            s.next_earnings_date = date
            s.next_earnings_hour = row['hour']
            s.next_earnings_est_eps = row['epsEstimate']
          end

          details = (s.next_earnings_details ||= [])
          details.reject! { |d| d['date'] == row['date'] }

          details << {
            date: row['date'],
            hour: row['hour'],
            eps_estimate: row['epsEstimate'],
            eps_actual: row['epsActual'],
            revenue_estimate: row['revenueEstimate'],
            revenue_actual: row['revenueActual'],
            quarter: row['quarter'],
            year: row['year']
          }

          s.save
        end
      end

      private

      def recommendation_mean(rec_details)
        return nil if rec_details.blank?

        value = total = 0
        rec_details.each do |_, data|
          value += 1 * data[0] + 2 * data[1] + 3 * data[2] + 4 * data[3] + 5 * data[4]
          total += data[0] + data[1] + data[2] + data[3] + data[4]
        end

        (value.to_f / total).round(2)
      end

      attr_accessor :exchange_class, :stock_class, :stock_ar_class
    end
  end
end
