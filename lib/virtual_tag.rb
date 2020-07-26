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

  def find_stock_ids
    @db_expression.call
  end

  def eligible?(stock)
    @ruby_expression.call(stock)
  end

  private

  ALL = [
      VirtualTag.new('S&P 500', 'S&P 500 Index', ->(stock) { stock.sp500 }, ->() { Stock.where(sp500: true) } ),
      VirtualTag.new('Nasdaq 100', 'Nasdaq 100 Index', ->(stock) { stock.nasdaq100 }, ->() { Stock.where(nasdaq100: true) } ),
      VirtualTag.new('Dow Jones', 'Dow Jones Industrial Average', ->(stock) { stock.dowjones }, ->() { Stock.where(dowjones: true) } ),
  ].freeze

end
