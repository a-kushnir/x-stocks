class Dividend

  def date_range
    from_date = Date.today.at_beginning_of_month
    to_date = from_date + 1.year - 1.day
    @date_range ||= [from_date, to_date]
  end

  def months
    from_date = date_range.first

    results = []

    12.times do
      results << from_date
      from_date = from_date >> 1
    end

    results
  end

  def estimate(stock)
    last_div = stock.periodic_dividend_details.last
    return nil unless last_div
    return nil if stock.div_suspended?

    payment_date = Date.parse(last_div['payment_date'])
    amount = last_div['amount'].to_d

    results = []
    results << { payment_date: payment_date, amount: amount }

    case stock.dividend_frequency
    when 'annual'
      (2*1).times do
        payment_date = payment_date >> 12
        results << { payment_date: payment_date, amount: amount }
      end
    when 'semi-annual'
      (2*2).times do
        payment_date = payment_date >> 6
        results << { payment_date: payment_date, amount: amount }
      end
    when 'quarterly'
      (2*4).times do
        payment_date = payment_date >> 3
        results << { payment_date: payment_date, amount: amount }
      end
    when 'monthly'
      (3).times do
        payment_date = payment_date << 1
      end
      (2*12).times do
        payment_date = payment_date >> 1
        results << { payment_date: payment_date, amount: amount }
      end
    else
      # Do nothing
    end

    from_date, to_date = date_range
    results.select! do |row|
      row[:payment_date] >= from_date &&
      row[:payment_date] <= to_date
    end

    results.each do |row|
      row[:month] = row[:payment_date].at_beginning_of_month
    end

    results
  end

end
