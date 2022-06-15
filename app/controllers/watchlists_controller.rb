# frozen_string_literal: true

# Controller to manage stock watchlists
class WatchlistsController < ApplicationController
  include StocksControllerConcern

  def index
    watchlists = user_watchlists.all

    @table = table
    @table.sort { |column, direction| watchlists = watchlists.reorder(column => direction) }
    @table.filter { |query| watchlists = watchlists.where('LOWER(watchlists.name) like LOWER(:query)', query: "%#{query}%") }

    watchlists = watchlists.all
    watchlists = @table.paginate(watchlists)
    return unless stale?(watchlists)

    populate_data(watchlists)

    @page_title = t('watchlists.pages.watchlists')
  end

  def show
    @watchlist = find_user_watchlist

    stocks = XStocks::AR::Stock.where(symbol: @watchlist.symbols)

    @table = stock_table
    @table.sort { |column, direction| stocks = stocks.reorder(column => direction) }
    @table.filter { |query| stocks = stocks.where('LOWER(stocks.symbol) like LOWER(:query) or LOWER(stocks.company_name) like LOWER(:query)', query: "%#{query}%") }

    stocks = stocks.all
    stocks = @table.paginate(stocks)
    return unless stale?(stocks)

    stocks.each { |stock| @table.rows << stock_table_row(stock) }

    @page_title = @watchlist.name
  end

  def new
    @watchlist = user_watchlists.new
  end

  def create
    @watchlist = user_watchlists.new
    @watchlist.attributes = watchlist_params

    if @watchlist.save
      redirect_to action: 'index'
    else
      render action: 'new'
    end
  end

  def edit
    @watchlist = find_user_watchlist
  end

  def update
    @watchlist = find_user_watchlist
    @watchlist.attributes = watchlist_params

    if @watchlist.save
      redirect_to action: 'index'
    else
      render action: 'new'
    end
  end

  def destroy
    @watchlist = find_user_watchlist
  end

  private

  def render(*args)
    @page_title ||= @watchlist && !@watchlist.new_record? ? @watchlist.name : t('watchlists.pages.new_watchlist')
    @page_menu_item = :watchlists
    super
  end

  def user_watchlists
    current_user.watchlists
  end

  def find_user_watchlist
    user_watchlists.find_by_hashid(params[:id])
  end

  def table
    table = DataTable::Table.new(params)

    table.init_columns do |columns|
      columns << DataTable::Column.new(code: 'nme', label: t('watchlists.columns.name'), formatter: 'link', sorting: 'watchlists.name', default: true)
      columns << DataTable::Column.new(code: 'cnt', label: t('watchlists.columns.stocks'), formatter: 'number', default: true)
    end
  end

  def populate_data(watchlists)
    watchlists.map do |watchlist|
      @table.rows << [
        [watchlist.name, watchlist_path(watchlist.hashid)],
        (watchlist.symbols || []).size
      ]
    end
  end

  def watchlist_params
    params
      .require(:x_stocks_ar_watchlist)
      .permit(:name)
  end
end
