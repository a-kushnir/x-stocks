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

    service = SERVICES[params[:id]]

    if service
      service[:proc].call(params)
      flash[:notice] = "#{service[:name]} complete"
    else
      flash[:notice] = "Invalid service"
    end

    redirect_to action: 'index'
  end

  private

  SERVICES = HashWithIndifferentAccess.new({
      hourly_all_finnhub: {
          name: 'Update stock prices [Finnhub] / Auto (Hourly)',
          prev: ->() { Etl::Refresh::Finnhub.new.hourly_last_run_at },
          proc: ->(args) do
            Etl::Refresh::Finnhub.new.hourly_all_stocks!
          end
      },
      hourly_one_finnhub: {
          name: 'Update stock prices [Finnhub]',
          args: [:stock_id],
          proc: ->(args) do
            Etl::Refresh::Finnhub.new.hourly_one_stock!(stock)
          end
      },
      daily_all_yahoo: {
          name: 'Update stock information [Yahoo] / Auto (Daily)',
          prev: ->() { Etl::Refresh::Yahoo.new.daily_last_run_at },
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
          name: 'Update stock information [Finnhub] / Auto (Daily)',
          prev: ->() { Etl::Refresh::Finnhub.new.daily_last_run_at },
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
          name: 'Update stock dividends [IEX Cloud] / Auto (Weekly)',
          prev: ->() { Etl::Refresh::Iexapis.new.weekly_last_run_at },
          proc: ->(args) do
            Etl::Refresh::Iexapis.new.weekly_all_stocks!
          end
      },
      weekly_one_iexapis: {
          name: 'Update stock dividends [IEX Cloud]',
          args: [:stock_id],
          proc: ->(args) do
            stock = Stock.find_by!(id: args[:stock_id])
            Etl::Refresh::Iexapis.new.weekly_one_stock!(stock)
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
  })

end
