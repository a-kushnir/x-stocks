# frozen_string_literal: true

module XStocks
  class Stock
    # Calculates stock score using multiple parameters
    module MetaScore
      def calculate_meta_score(stock)
        details = {}

        if stock.yahoo_rec
          value = convert(4.5..1.5, 0..100, stock.yahoo_rec)
          details[:yahoo_rec] = { value: stock.yahoo_rec.to_f, score: value, weight: 2 }
        end

        if stock.finnhub_rec
          value = convert(4.5..1.5, 0..100, stock.finnhub_rec)
          details[:finnhub_rec] = { value: stock.finnhub_rec.to_f, score: value, weight: 2 }
        end

        if !stock.payout_ratio.to_f.zero? && !index?(stock)
          value = if stock.payout_ratio.negative?
                    convert(-50..0, 0..30, stock.payout_ratio)
                  elsif stock.payout_ratio < 75
                    convert(0..75, 100..80, stock.payout_ratio)
                  else
                    convert(75..150, 80..0, stock.payout_ratio)
                  end

          details[:payout_ratio] = { value: stock.payout_ratio.to_f, score: value, weight: 2 }
        end

        if stock.dividend_rating
          value = convert(0..5, 0..100, stock.dividend_rating)
          details[:div_safety] = { value: stock.dividend_rating.to_f, score: value, weight: 4 }
        end

        stock.metascore, stock.metascore_details = result(details)
      end

      def metascore_details(stock)
        return unless stock.metascore_details

        stock.metascore_details.map do |k, v|
          case k
          when 'yahoo_rec'
            "#{v['score']}: Yahoo Rec. #{v['value']} #{rec_human(v['value'])}"
          when 'finnhub_rec'
            "#{v['score']}: Finnhub Rec. #{v['value']} #{rec_human(v['value'])}"
          when 'payout_ratio'
            "#{v['score']}: Payout #{v['value']}%"
          when 'div_safety'
            "#{v['score']}: Div Safety #{v['value']}"
          else
            "#{v['score']}: #{k} #{v['value']}"
          end
        end.join("\n")
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

      def index?(stock)
        stock.issue_type == 'et'
      end

      def lerp(min, max, value)
        value = 0 if value.negative?
        value = 1 if value > 1
        min + (max - min) * value.to_f
      end

      def inv_lerp(min, max, value)
        if min < max
          return 0 if value <= min
          return 1 if value >= max
        else
          return 0 if value >= min
          return 1 if value <= max
        end

        (value - min).to_f / (max - min)
      end

      def convert(src_range, dst_range, value)
        value = inv_lerp(src_range.begin, src_range.end, value)
        lerp(dst_range.begin, dst_range.end, value)
      end

      def result(meta_score_details)
        meta_score_details = nil if meta_score_details.blank?

        if meta_score_details
          meta_score_details.each_value { |v| v[:score] = v[:score].to_i }
          value = meta_score_details.values.map { |v| v[:score] * v[:weight] }.sum
          base = meta_score_details.values.map { |v| v[:weight] }.sum
          meta_score = value / base
        else
          meta_score = nil
        end

        [meta_score, meta_score_details]
      end
    end
  end
end
