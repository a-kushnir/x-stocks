# frozen_string_literal: true

# Calculates dividend calendar
class DividendCalculator
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

  def estimate(stock, est_records: nil, history_records: nil, date_range: nil)
    last_div = stock.dividends.regular.first
    return [] unless last_div
    return [] if stock.div_suspended?

    declaration_date, ex_dividend_date, pay_date = last_div.values_at(:declaration_date, :ex_dividend_date, :pay_date, :amount)
    amount = est_amount(stock)

    estimates = []

    case last_div.frequency
    when XStocks::Dividends::Frequency::ANNUALLY
      (2 * 1).times do
        declaration_date = declaration_date >> 12
        ex_dividend_date = ex_dividend_date >> 12
        pay_date = pay_date >> 12
        estimates << new_est_dividend(last_div, declaration_date, ex_dividend_date, pay_date, amount)
      end
    when XStocks::Dividends::Frequency::BI_ANNUALLY
      (2 * 2).times do
        declaration_date = declaration_date >> 6
        ex_dividend_date = ex_dividend_date >> 6
        pay_date = pay_date >> 6
        estimates << new_est_dividend(last_div, declaration_date, ex_dividend_date, pay_date, amount)
      end
    when XStocks::Dividends::Frequency::QUARTERLY
      (2 * 4).times do
        declaration_date = declaration_date >> 3
        ex_dividend_date = ex_dividend_date >> 3
        pay_date = pay_date >> 3
        estimates << new_est_dividend(last_div, declaration_date, ex_dividend_date, pay_date, amount)
      end
    when XStocks::Dividends::Frequency::MONTHLY
      (2 * 12).times do
        declaration_date = declaration_date >> 1
        ex_dividend_date = ex_dividend_date >> 1
        pay_date = pay_date >> 1
        estimates << new_est_dividend(last_div, declaration_date, ex_dividend_date, pay_date, amount)
      end
    end

    results = est_records ? estimates.reverse.last(est_records) : estimates.reverse
    results += history_records ? stock.dividends.first(history_records) : stock.dividends

    if date_range
      from_date, to_date = date_range
      results.select! do |row|
        row.pay_date >= from_date &&
          row.pay_date <= to_date
      end
    end

    results
  end

  def timeline(positions)
    estimates = positions.map { |position| estimate(XStocks::Stock.new(position.stock), date_range: date_range) }.compact.flatten
    estimates.sort_by(&:pay_date)
  end

  private

  def est_amount(stock, sample: 12, same: 3)
    last12 = stock.dividends.regular.first(sample)
    stable = last12.size.times.any? do |index|
      amounts = last12[index, same].map(&:amount)
      amounts.size == same && amounts.uniq.size == 1
    end

    stable ? last12.first.amount : (last12.sum(&:amount) / last12.size).round(4)
  end

  def new_est_dividend(template, declaration_date, ex_dividend_date, pay_date, amount)
    template.stock.dividends.new(
      declaration_date: declaration_date,
      ex_dividend_date: ex_dividend_date,
      pay_date: pay_date,
      amount: amount,
      **template.slice(:dividend_type, :currency, :frequency)
    )
  end

  attr_reader :date
end
