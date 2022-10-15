# frozen_string_literal: true

# Calculates dividend calendar
class Dividend
  def initialize(date: Date)
    @date = date
  end

  def date_range
    from_date = date.today.at_beginning_of_month
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

  def estimate(stock, include_stock: false)
    last_div = stock.dividends.regular.first
    return nil unless last_div
    return nil if stock.div_suspended?

    pay_date = last_div.pay_date
    ex_dividend_date = last_div.ex_dividend_date
    amount = last_div.amount

    results = []

    case last_div.frequency
    when XStocks::Dividends::Frequency::ANNUALLY
      results << { pay_date: pay_date, ex_dividend_date: ex_dividend_date, amount: amount }
      (2 * 1).times do
        pay_date = pay_date >> 12
        ex_dividend_date = ex_dividend_date >> 12
        results << { pay_date: pay_date, ex_dividend_date: ex_dividend_date, amount: amount }
      end
    when XStocks::Dividends::Frequency::BI_ANNUALLY
      results << { pay_date: pay_date, ex_dividend_date: ex_dividend_date, amount: amount }
      (2 * 2).times do
        pay_date = pay_date >> 6
        ex_dividend_date = ex_dividend_date >> 6
        results << { pay_date: pay_date, ex_dividend_date: ex_dividend_date, amount: amount }
      end
    when XStocks::Dividends::Frequency::QUARTERLY
      results << { pay_date: pay_date, ex_dividend_date: ex_dividend_date, amount: amount }
      (2 * 4).times do
        pay_date = pay_date >> 3
        ex_dividend_date = ex_dividend_date >> 3
        results << { pay_date: pay_date, ex_dividend_date: ex_dividend_date, amount: amount }
      end
    when XStocks::Dividends::Frequency::MONTHLY
      3.times do
        pay_date = pay_date << 1
        ex_dividend_date = ex_dividend_date << 1
      end
      (2 * 12).times do
        pay_date = pay_date >> 1
        ex_dividend_date = ex_dividend_date >> 1
        results << { pay_date: pay_date, ex_dividend_date: ex_dividend_date, amount: amount }
      end
    else
      results << { pay_date: pay_date, ex_dividend_date: ex_dividend_date, amount: amount }
    end

    from_date, to_date = date_range
    results.select! do |row|
      row[:pay_date] >= from_date &&
        row[:pay_date] <= to_date
    end

    results.each do |row|
      row[:month] = row[:pay_date].at_beginning_of_month
      row[:stock] = stock if include_stock
    end

    results
  end

  def timeline(positions)
    estimates = positions.map { |position| estimate(XStocks::Stock.new(position.stock), include_stock: true) }.compact.flatten
    estimates.sort_by { |estimate| estimate[:pay_date] }
  end

  private

  attr_reader :date
end
