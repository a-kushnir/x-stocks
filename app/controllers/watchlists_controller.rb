# frozen_string_literal: true

# Controller to manage stock watchlists
class WatchlistsController < ApplicationController
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
    @watchlist = user_watchlists.find(params[:id])
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
    @watchlist = user_watchlists.find(params[:id])
  end

  def update
    @watchlist = user_watchlists.find(params[:id])
    @watchlist.attributes = watchlist_params

    if @watchlist.save
      redirect_to action: 'index'
    else
      render action: 'new'
    end
  end

  def destroy
    @watchlist = user_watchlists.find(params[:id])
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

  def table
    table = DataTable::Table.new(params)

    table.init_columns do |columns|
      columns << DataTable::Column.new(code: 'nme', label: t('watchlists.columns.name'), formatter: 'string', sorting: 'watchlists.name', default: true)
    end
  end

  def populate_data(watchlists)
    watchlists.map do |watchlist|
      @table.rows << [
        watchlist.name
      ]
    end
  end

  def watchlist_params
    params
      .require(:x_stocks_ar_watchlist)
      .permit(:name)
  end
end
