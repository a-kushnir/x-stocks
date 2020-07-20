class Metascore

  def calculate(stock)
    details = {}

    if stock.yahoo_rec
      value = convert((4.5)..(1.5), 0..100, stock.yahoo_rec)
      details[:yahoo_rec] = {value: stock.yahoo_rec.to_f, score: value, weight: 2}
    end

    if stock.finnhub_rec
      value = convert((4.5)..(1.5), 0..100, stock.finnhub_rec)
      details[:finnhub_rec] = {value: stock.finnhub_rec.to_f, score: value, weight: 2}
    end

    if stock.payout_ratio && !stock.index?
      value = if stock.payout_ratio < 0
                convert(-50..0, 0..30, stock.payout_ratio)
              elsif stock.payout_ratio < 75
                convert(0..75, 100..80, stock.payout_ratio)
              else
                convert(75..150, 80..0, stock.payout_ratio)
              end

      details[:payout_ratio] = {value: stock.payout_ratio.to_f, score: value, weight: 2}
    end

    if stock.dividend_rating
      value = convert(0..5, 0..100, stock.dividend_rating)
      details[:div_safety] = {value: stock.dividend_rating.to_f, score: value, weight: 4}
    end

    result(details)
  end

  private

  def lerp(min, max, value)
    value = 0 if value < 0
    value = 1 if value > 1
    min + (max - min) * value.to_f
  end

  def inv_lerp(min, max, value)
    if min < max
      return 0 if value <= min
      return 1 if value >= max
      (value - min).to_f / (max - min)
    else
      return 0 if value >= min
      return 1 if value <= max
      (value - min).to_f / (max - min)
    end
  end

  def convert(src_range, dst_range, value)
    value = inv_lerp(src_range.begin, src_range.end, value)
    lerp(dst_range.begin, dst_range.end, value)
  end

  def result(details)
    details = nil if details.blank?

    if details
      details.each_value { |v| v[:score] = v[:score].to_i }
      metascore = details.values.map {|v| v[:score] * v[:weight] }.sum / details.values.map {|v| v[:weight] }.sum
    else
      metascore = nil
    end

    [metascore, details]
  end

end
