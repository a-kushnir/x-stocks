class ServicesController < ApplicationController

  def index
    @services = SERVICES
    @stocks = Stock.all

    @page_title = 'Services'
    @page_menu_item = :services
  end

  def update
    @page_title = 'Services'
    @page_menu_item = :services

    find_service do |service|
      service[:proc].call(params)
      flash[:notice] = "#{service[:name]} complete"
      redirect_to action: 'index'
    end
  end

  def log
    find_service do |service|
      serv = service[:service] ? Service.find_by(key: service[:service]) : nil
      send_data(serv&.log, filename: 'service-log.txt', type: 'text/plain')
    end
  end

  def error
    find_service do |service|
      serv = service[:service] ? Service.find_by(key: service[:service]) : nil
      send_data(serv&.error, filename: 'service-error.txt', type: 'text/plain')
    end
  end

  def run
    if Service.where('locked_at < ?', 1.hour.ago).exists?
      render json: {result: 'locked'}

    elsif Etl::Refresh::Finnhub.new.hourly_all_stocks?
      Etl::Refresh::Finnhub.new.hourly_all_stocks
      render json: {result: 'success'}

    else
      Etl::Refresh::Yahoo.new.daily_all_stocks
      Etl::Refresh::Finnhub.new.daily_all_stocks
      Etl::Refresh::Iexapis.new.weekly_all_stocks
      Etl::Refresh::Dividend.new.weekly_all_stocks
      render json: {result: 'success'}

    end
  end

  private

  def find_service
    service = SERVICES[params[:id]]
    if service
      yield service
    else
      flash[:notice] = "Invalid service"
      redirect_to action: 'index'
    end
  end

  SERVICES = HashWithIndifferentAccess.new({
      hourly_all_finnhub: {
          service: 'stock_prices',
          name: 'Update stock prices [Finnhub]',
          schedule: 'Hourly',
          proc: ->(args) do
            Etl::Refresh::Finnhub.new.hourly_all_stocks!
          end
      },
      hourly_one_finnhub: {
          name: 'Update stock prices [Finnhub]',
          args: [:stock_id],
          proc: ->(args) do
            stock = Stock.find_by!(id: args[:stock_id])
            Etl::Refresh::Finnhub.new.hourly_one_stock!(stock)
          end
      },
      daily_all_yahoo: {
          service: 'daily_yahoo',
          name: 'Update stock information [Yahoo]',
          schedule: 'Daily',
          proc: ->(args) do
            Etl::Refresh::Yahoo.new.daily_all_stocks!
          end
      },
      daily_one_yahoo: {
          name: 'Update stock information [Yahoo]',
          args: [:stock_id],
          proc: ->(args) do
            stock = Stock.find_by!(id: args[:stock_id])
            Etl::Refresh::Yahoo.new.daily_one_stock!(stock)
          end
      },
      daily_all_finnhub: {
          service: 'daily_finnhub',
          name: 'Update stock information [Finnhub]',
          schedule: 'Daily',
          proc: ->(args) do
            Etl::Refresh::Finnhub.new.daily_all_stocks!
          end
      },
      daily_one_finnhub: {
          name: 'Update stock information [Finnhub]',
          args: [:stock_id],
          proc: ->(args) do
            stock = Stock.find_by!(id: args[:stock_id])
            Etl::Refresh::Finnhub.new.daily_one_stock!(stock)
          end
      },
      weekly_all_iexapis: {
          service: 'weekly_iexapis',
          name: 'Update stock dividends [IEX Cloud]',
          schedule: 'Weekly',
          proc: ->(args) do
            Etl::Refresh::Iexapis.new.weekly_all_stocks!
          end
      },
      weekly_one_iexapis: {
          name: 'Update stock dividends [IEX Cloud]',
          args: [:stock_id],
          proc: ->(args) do
            stock = Stock.find_by!(id: args[:stock_id])
            Etl::Refresh::Iexapis.new.weekly_one_stock!(stock, nil, immediate: true)
          end
      },
      weekly_all_dividend: {
          service: 'weekly_dividend',
          name: 'Update stock dividends [Dividend.com]',
          schedule: 'Weekly',
          proc: ->(args) do
            Etl::Refresh::Dividend.new.weekly_all_stocks!
          end
      },
      weekly_one_dividend: {
          name: 'Update stock dividends [Dividend.com]',
          args: [:stock_id],
          proc: ->(args) do
            stock = Stock.find_by!(id: args[:stock_id])
            Etl::Refresh::Dividend.new.weekly_one_stock!(stock)
          end
      },
      company_information: {
          name: 'Load company information [Finnhub] [IEX Cloud] [Yahoo]',
          args: [:stock_id],
          proc: ->(args) do
            stock = Stock.find_by!(id: args[:stock_id])
            Etl::Refresh::Company.new.one_stock!(stock)
          end
      },
      slickcharts: {
          name: 'S&P 500, Nasdaq 100 and Dow Jones [SlickCharts]',
          proc: ->(args) do
            Etl::Refresh::Slickcharts.new.all_stocks!
          end
      },
  })

end
