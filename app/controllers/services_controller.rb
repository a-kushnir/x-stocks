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
      all_finnhub_prices: {
          name: 'Update stock prices [Finnhub] / Auto (Hourly)',
          prev: ->() { Config[:stock_price_updated_at] },
          proc: ->(args) do
            Etl::DataRefresh.new.all_financial_data!
          end
      },
      one_finnhub_prices: {
          name: 'Update stock prices [Finnhub]',
          args: [:stock_id],
          proc: ->(args) do
            stock = Stock.find_by!(id: args[:stock_id])
            Etl::DataRefresh.new.financial_data!(stock)
          end
      },
      all_yahoo_data: {
          name: 'Update stock information [Yahoo] / Auto (Daily)',
          prev: ->() { Config[:yahoo_updated_at] },
          proc: ->(args) do
            Etl::DataRefresh.new.all_yahoo_data!
          end
      },
      one_yahoo_data: {
          name: 'Update stock information [Yahoo]',
          args: [:stock_id],
          proc: ->(args) do
            stock = Stock.find_by!(id: args[:stock_id])
            Etl::DataRefresh.new.yahoo_data!(stock)
          end
      },
      all_finnhub_data: {
          name: 'Update stock information [Finnhub] / Auto (Daily)',
          prev: ->() { Config[:finnhub_updated_at] },
          proc: ->(args) do
            Etl::DataRefresh.new.all_finnhub_data!
          end
      },
      one_finnhub_data: {
          name: 'Update stock information [Finnhub]',
          args: [:stock_id],
          proc: ->(args) do
            stock = Stock.find_by!(id: args[:stock_id])
            Etl::DataRefresh.new.finnhub_data!(stock)
          end
      },
  })

end
