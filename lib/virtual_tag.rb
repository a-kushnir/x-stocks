class VirtualTag

  attr_reader :name
  attr_reader :description

  def initialize(name, description, ruby_expression, db_expression)
    @name = name
    @description = description
    @ruby_expression = ruby_expression
    @db_expression = db_expression
  end

  def self.all
    ALL
  end

  def self.find(name)
    all.detect {|tag| tag.name == name }
  end

  def find_stock_ids(user)
    @db_expression.call(user)
  end

  def eligible?(position)
    @ruby_expression.call(position)
  end

  private

  ALL = [
      VirtualTag.new('Dividend Achiever', 'Dividend Achievers (≥10 years)', ->(position) { position.stock.dividend_growth_years && position.stock.dividend_growth_years >= 10 }, ->(user) { Stock.where('dividend_growth_years >= 10') } ),
      VirtualTag.new('Dividend Contender', 'Dividend Contenders (10-24 years)', ->(position) { position.stock.dividend_growth_years && position.stock.dividend_growth_years >= 10 && position.stock.dividend_growth_years < 25 }, ->(user) { Stock.where('dividend_growth_years >= 10 and dividend_growth_years < 25') } ),
      VirtualTag.new('Dividend Champion', 'Dividend Champions (≥25 years)', ->(position) { position.stock.dividend_growth_years && position.stock.dividend_growth_years >= 25 }, ->(user) { Stock.where('dividend_growth_years >= 25') } ),
      VirtualTag.new('Safe Dividend', 'Safe Dividends (Rating ≥4.0)', ->(position) { position.stock.dividend_rating && position.stock.dividend_rating >= 4.0 }, ->(user) { Stock.where('dividend_rating >= 4.0') } ),
      VirtualTag.new('High Dividend Growth', 'High Dividend Growth (≥5.0%)', ->(position) { position.stock.dividend_growth_3y.to_f >= 5.0 || position.stock.dividend_growth_5y.to_f >= 5.0 }, ->(user) { Stock.where('dividend_growth_3y >= 5.0 or dividend_growth_5y >= 5.0') } ),
      VirtualTag.new('S&P 500', 'S&P 500 Index', ->(position) { position.stock.sp500 }, ->(user) { Stock.where(sp500: true) } ),
      VirtualTag.new('Nasdaq 100', 'Nasdaq 100 Index', ->(position) { position.stock.nasdaq100 }, ->(user) { Stock.where(nasdaq100: true) } ),
      VirtualTag.new('Dow Jones', 'Dow Jones Industrial Average', ->(position) { position.stock.dowjones }, ->(user) { Stock.where(dowjones: true) } ),
      VirtualTag.new('My Notes', 'My Notes', ->(position) { position.note.present? }, ->(user) { Position.where(user: user).pluck(:stock_id, :note).map {|stock_id, note| note.present? ? stock_id : nil }.compact }),
  ].freeze

end
