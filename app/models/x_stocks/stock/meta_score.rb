# frozen_string_literal: true

require 'math'

module XStocks
  class Stock
    # Calculates stock score using multiple parameters
    module MetaScore
      def calculate_meta_score
        details = {}

        if ar_stock.yahoo_rec
          value = convert(4.5..1.5, 0..100, ar_stock.yahoo_rec)
          details[:yahoo_rec] = { value: ar_stock.yahoo_rec.to_f, score: value, weight: 2 }
        end

        if ar_stock.finnhub_rec
          value = convert(4.5..1.5, 0..100, ar_stock.finnhub_rec)
          details[:finnhub_rec] = { value: ar_stock.finnhub_rec.to_f, score: value, weight: 2 }
        end

        if !ar_stock.payout_ratio.to_f.zero? && common_stock?
          value = if ar_stock.payout_ratio.negative?
                    convert(-50..0, 0..30, ar_stock.payout_ratio)
                  elsif ar_stock.payout_ratio < 75
                    convert(0..75, 100..80, ar_stock.payout_ratio)
                  else
                    convert(75..150, 80..0, ar_stock.payout_ratio)
                  end

          details[:payout_ratio] = { value: ar_stock.payout_ratio.to_f, score: value, weight: 2 }
        end

        if !ar_stock.pe_ratio_ttm.to_f.zero? && common_stock?
          value = if ar_stock.pe_ratio_ttm.negative?
                    0
                  elsif ar_stock.pe_ratio_ttm < 20
                    convert(0..20, 100..80, ar_stock.pe_ratio_ttm)
                  else
                    convert(20..50, 80..0, ar_stock.pe_ratio_ttm)
                  end

          details[:pe_ratio_ttm] = { value: ar_stock.pe_ratio_ttm.to_f, score: value, weight: 1 }
        end

        if ar_stock.dividend_rating
          value = convert(0..5, 0..100, ar_stock.dividend_rating)
          details[:div_safety] = { value: ar_stock.dividend_rating.to_f, score: value, weight: 4 }
        end

        if ar_stock.yahoo_discount
          value = convert(-50..+50, 0..100, ar_stock.yahoo_discount)
          details[:yahoo_discount] = { value: ar_stock.yahoo_discount.to_f, score: value, weight: 1 }
        end

        ar_stock.metascore, ar_stock.metascore_details = result(details)
      end

      def meta_score_details
        return unless ar_stock.metascore_details

        ar_stock.metascore_details.map do |k, v|
          score = v['score']
          value = v['value']

          case k
          when 'yahoo_rec'
            "#{score}: #{format('%<value>.2f', value: value.to_f)} (#{rec_human(value)}) Yahoo Rec."
          when 'finnhub_rec'
            "#{score}: #{format('%<value>.2f', value: value.to_f)} (#{rec_human(value)}) Finnhub Rec."
          when 'payout_ratio'
            "#{score}: #{format('%<value>.2f', value: value.to_f)}% Payout"
          when 'pe_ratio_ttm'
            "#{score}: #{format('%<value>.2f', value: value.to_f)} P/E Ratio"
          when 'div_safety'
            "#{score}: #{format('%<value>.1f', value: value.to_f)} (#{safety_human(value)}) Div. Safety"
          when 'yahoo_discount'
            "#{score}: #{'+' if value.positive?}#{format('%<value>.0f', value: value.to_f)}% Fair Value"
          else
            "#{score}: #{value} #{k}"
          end
        end.join("\n")
      end

      def price_range
        result = [
          ar_stock.week_52_low&.to_f,
          ar_stock.week_52_high&.to_f,
          ar_stock.current_price&.to_f,
          ar_stock.price_change&.to_f
        ]
        result unless result.include?(nil)
      end

      private

      def rec_human(value)
        if value.nil?
          nil
        elsif value <= 1.5
          'Str. Buy'
        elsif value <= 2.5
          'Buy'
        elsif value < 3.5
          'Hold'
        elsif value < 4.5
          'Sell'
        else
          'Str. Sell'
        end
      end

      def safety_human(value)
        if value.nil?
          nil
        elsif value >= 4.5
          'Very Safe'
        elsif value >= 3.5
          'Safe'
        elsif value >= 2.5
          'Borderline'
        elsif value >= 1.5
          'Unsafe'
        else
          'Very Unsafe'
        end
      end

      def convert(src_range, dst_range, value)
        value = Math.inv_lerp(src_range.begin, src_range.end, value)
        Math.lerp(dst_range.begin, dst_range.end, value)
      end

      def result(meta_score_details)
        meta_score_details = nil if meta_score_details.blank?

        if meta_score_details
          meta_score_details.each_value { |v| v[:score] = v[:score].to_i }
          value = meta_score_details.values.sum { |v| v[:score] * v[:weight] }
          base = meta_score_details.values.sum { |v| v[:weight] }
          meta_score = value / base
        else
          meta_score = nil
        end

        [meta_score, meta_score_details]
      end
    end
  end
end
