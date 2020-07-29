class ServiceRunner

  attr_reader :name
  attr_reader :lookup_code
  attr_reader :service_code
  attr_reader :schedule_code
  attr_reader :arguments
  attr_reader :proc

  def initialize(name, lookup_code, options, proc)
    @name = name
    @lookup_code = lookup_code
    @service_code = options[:service_code]
    @schedule_code = options[:schedule_code]
    @arguments = options[:arguments]
    @proc = proc
  end

  def self.all
    ALL
  end

  def self.find(lookup_code)
    all.detect {|tag| tag.lookup_code == lookup_code }
  end

  def service
    @service ||= Service.find_by(key: service_code) if service_code.present?
  end

  def run(args)
    proc.call(args)
  end

  private

  ALL = [
      ServiceRunner.new('Update stock prices [Finnhub]', 'hourly_all_finnhub', {service_code: 'stock_prices', schedule_code: 'Hourly'},
                        ->(args) do
                          Etl::Refresh::Finnhub.new.hourly_all_stocks!
                        end),

      ServiceRunner.new('Update stock prices [Finnhub]', 'hourly_one_finnhub', {arguments: [:stock_id]},
                        ->(args) do
                          stock = Stock.find_by!(id: args[:stock_id])
                          Etl::Refresh::Finnhub.new.hourly_one_stock!(stock)
                        end),

      ServiceRunner.new('Update stock information [Yahoo]', 'daily_all_yahoo', {service_code: 'daily_yahoo', schedule_code: 'Daily'},
                        ->(args) do
                          Etl::Refresh::Yahoo.new.daily_all_stocks!
                        end),

      ServiceRunner.new('Update stock information [Yahoo]', 'daily_one_yahoo', {arguments: [:stock_id]},
                        ->(args) do
                          stock = Stock.find_by!(id: args[:stock_id])
                          Etl::Refresh::Yahoo.new.daily_one_stock!(stock)
                        end),

      ServiceRunner.new('Update stock information [Finnhub]', 'daily_all_finnhub', {service_code: 'daily_finnhub', schedule_code: 'Daily'},
                        ->(args) do
                          Etl::Refresh::Finnhub.new.daily_all_stocks!
                        end),

      ServiceRunner.new('Update stock information [Finnhub]', 'daily_one_finnhub', {arguments: [:stock_id]},
                        ->(args) do
                          stock = Stock.find_by!(id: args[:stock_id])
                          Etl::Refresh::Finnhub.new.daily_one_stock!(stock)
                        end),

      ServiceRunner.new('Update stock dividends [IEX Cloud]', 'weekly_all_iexapis', {service_code: 'weekly_iexapis', schedule_code: 'Weekly'},
                        ->(args) do
                          Etl::Refresh::Iexapis.new.weekly_all_stocks!
                        end),

      ServiceRunner.new('Update stock dividends [IEX Cloud]', 'weekly_one_iexapis', {arguments: [:stock_id]},
                        ->(args) do
                          stock = Stock.find_by!(id: args[:stock_id])
                          Etl::Refresh::Iexapis.new.weekly_one_stock!(stock, nil, immediate: true)
                        end),

      ServiceRunner.new('Update stock dividends [Dividend.com]', 'weekly_all_dividend', {service_code: 'weekly_dividend', schedule_code: 'Weekly'},
                        ->(args) do
                          Etl::Refresh::Dividend.new.weekly_all_stocks!
                        end),

      ServiceRunner.new('Update stock dividends [Dividend.com]', 'weekly_one_dividend', {arguments: [:stock_id]},
                        ->(args) do
                          stock = Stock.find_by!(id: args[:stock_id])
                          Etl::Refresh::Dividend.new.weekly_one_stock!(stock)
                        end),

      ServiceRunner.new('Load company information [Finnhub] [IEX Cloud] [Yahoo]', 'company_information', {arguments: [:stock_id]},
                        ->(args) do
                          stock = Stock.find_by!(id: args[:stock_id])
                          Etl::Refresh::Company.new.one_stock!(stock)
                        end),

      ServiceRunner.new('S&P 500, Nasdaq 100 and Dow Jones [SlickCharts]', 'slickcharts', {},
                        ->(args) do
                          Etl::Refresh::Slickcharts.new.all_stocks!
                        end),
  ].freeze

end
