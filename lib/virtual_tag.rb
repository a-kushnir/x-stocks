class VirtualTag

  attr_reader :name
  attr_reader :description
  attr_reader :fa_icon
  attr_reader :sort_order

  def initialize(name, description, ruby_expression, db_expression, fa_icon, sort_order = nil)
    @name = name
    @description = description
    @ruby_expression = ruby_expression
    @db_expression = db_expression
    @fa_icon = fa_icon
    @sort_order = sort_order
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
      VirtualTag.new('Dividend Achiever', '≥ 10 years of Dividend Growth', ->(position) { position.stock.dividend_growth_years && position.stock.dividend_growth_years >= 10 }, ->(user) { Stock.where('dividend_growth_years >= 10') }, 'fa-line-chart' ),
      VirtualTag.new('Dividend Contender', '10-24 years of Dividend Growth', ->(position) { position.stock.dividend_growth_years && position.stock.dividend_growth_years >= 10 && position.stock.dividend_growth_years < 25 }, ->(user) { Stock.where('dividend_growth_years >= 10 and dividend_growth_years < 25') }, 'fa-line-chart' ),
      VirtualTag.new('Dividend Champion', '≥ 25 years of Dividend Growth', ->(position) { position.stock.dividend_growth_years && position.stock.dividend_growth_years >= 25 }, ->(user) { Stock.where('dividend_growth_years >= 25') }, 'fa-line-chart' ),
      VirtualTag.new('High Dividend Growth', '3Y or 5Y Dividend Growth ≥ 5.0%', ->(position) { position.stock.dividend_growth_3y.to_f >= 5.0 || position.stock.dividend_growth_5y.to_f >= 5.0 }, ->(user) { Stock.where('dividend_growth_3y >= 5.0 or dividend_growth_5y >= 5.0') }, 'fa-line-chart' ),
      VirtualTag.new('Safe Dividend', 'Dividend Safety ≥ 4.0', ->(position) { position.stock.dividend_rating && position.stock.dividend_rating >= 4.0 }, ->(user) { Stock.where('dividend_rating >= 4.0') }, 'fa-shield', '10-desc' ),
      VirtualTag.new('High Score', 'Score > 60', ->(position) { position.stock.metascore && position.stock.metascore > 60 }, ->(user) { Stock.where('metascore > 60') }, 'fa-shield', '12-desc' ),
      VirtualTag.new('S&P 500', 'S&P 500 Index', ->(position) { position.stock.sp500 }, ->(user) { Stock.where(sp500: true) }, 'fa-list-ol' ),
      VirtualTag.new('Nasdaq 100', 'Nasdaq 100 Index', ->(position) { position.stock.nasdaq100 }, ->(user) { Stock.where(nasdaq100: true) }, 'fa-list-ol' ),
      VirtualTag.new('Dow Jones', 'Dow Jones Industrial Average', ->(position) { position.stock.dowjones }, ->(user) { Stock.where(dowjones: true) }, 'fa-list-ol' ),
      VirtualTag.new('Ex Date Soon', 'Ex Date ≤ 1 month in the future', ->(position) { position.stock.next_div_ex_date && position.stock.next_div_ex_date < 1.month.since }, ->(user) { Stock.where(['next_div_ex_date < ?', 1.month.since]) }, 'fa-calendar', '11-asc'),
      VirtualTag.new('My Note', 'My Note is Present', ->(position) { position.note.present? }, ->(user) { Position.where(user: user).pluck(:stock_id, :note).map {|stock_id, note| note.present? ? stock_id : nil }.compact }, 'fa-thumb-tack'),
  ].freeze

end
