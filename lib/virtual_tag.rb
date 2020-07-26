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
      VirtualTag.new('S&P 500', 'S&P 500 Index', ->(position) { position.stock.sp500 }, ->(user) { Stock.where(sp500: true) } ),
      VirtualTag.new('Nasdaq 100', 'Nasdaq 100 Index', ->(position) { position.stock.nasdaq100 }, ->(user) { Stock.where(nasdaq100: true) } ),
      VirtualTag.new('Dow Jones', 'Dow Jones Industrial Average', ->(position) { position.stock.dowjones }, ->(user) { Stock.where(dowjones: true) } ),
      VirtualTag.new('My Notes', 'My Notes', ->(position) { position.note.present? }, ->(user) { Position.where(user: user).pluck(:stock_id, :note).map {|stock_id, note| note.present? ? stock_id : nil }.compact }),
  ].freeze

end
