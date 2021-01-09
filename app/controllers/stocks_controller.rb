# frozen_string_literal: true

class StocksController < ApplicationController
  include StocksHelper

  def index
    return if handle_goto_param?

    stock_ids = handle_tag_param

    @stocks = Stock
    @stocks = @stocks.where(id: stock_ids) if stock_ids.present?
    @stocks = @stocks.all

    @positions = Position.where(stock: @stocks, user: current_user).all

    @columns = columns

    @page_title = 'Stocks'
    @page_menu_item = :stocks
  end

  def show
    @stock = find_stock
    not_found && return unless @stock

    Etl::Refresh::Finnhub.new.hourly_one_stock!(@stock) rescue nil
    @position = Position.find_or_initialize_by(stock: @stock, user: current_user)

    set_page_title
  end

  def new
    @stock = Stock.new
    set_page_title
  end

  def create
    @stock = Stock.new(stock_params)

    if @stock.save
      Service.lock(:company_information, force: true) do |logger|
        logger.text_size_limit = nil
        Etl::Refresh::Company.new.one_stock!(@stock, logger: logger)
      end

      redirect_to stock_path(@stock)
    else
      set_page_title
      render action: 'new'
    end
  end

  def destroy
    @stock = find_stock
    not_found && return unless @stock

    @stock.destroy
    flash[:notice] = "#{@stock} stock deleted"
    redirect_to stocks_path
  end

  private

  def set_page_title
    @page_title = @stock.new_record? ? 'New Stock' : @stock.to_s
    @page_menu_item = :stocks
  end

  def find_stock
    Stock.find_by(symbol: params[:id])
  end

  def stock_params
    params.require(:stock).permit(:symbol)
  end

  def handle_goto_param?
    value = params[:goto]
    return false if value.blank?

    stock = Stock.find_by(symbol: value.upcase)
    if stock
      redirect_to stock_path(stock)
      return true
    end

    stocks = Stock.where('company_name ILIKE ?', "%#{value.downcase}%").all
    if stocks.count == 1
      redirect_to stock_path(stocks.first)
      return true
    end

    redirect_to url_for(search: value)
    true
  end

  def handle_tag_param
    @tag = params[:tag]
    return if @tag.blank?

    virtual_tag = VirtualTag.find(@tag)

    stock_ids =
      if virtual_tag
        virtual_tag.find_stock_ids(current_user)
      else
        Tag.where(name: @tag).pluck(:stock_id)
      end

    @tag = nil unless stock_ids.present?
    stock_ids
  end

  def columns
    columns = []

    columns << { label: 'Company', index: index = 1, default: true }
    columns << { label: 'Price', index: index += 1, default: true }
    columns << { label: 'Change', index: index += 1, default: true }
    columns << { label: 'Change %', index: index += 1, default: true }
    columns << { label: 'Fair Value', index: index += 1, default: true }
    columns << { label: 'Est. Annual Div.', index: index += 1, default: true }
    columns << { label: 'Est. Field %', index: index += 1, default: true }
    columns << { label: 'Div. Change %', index: index += 1 }
    columns << { label: 'Payout %', index: index += 1 }
    columns << { label: 'Yahoo Rec.', index: index += 1, default: true }
    columns << { label: 'Finnhub Rec.', index: index += 1, default: true }
    columns << { label: 'Div. Safety', index: index += 1, default: true }
    columns << { label: 'Ex Date', index: index += 1 }
    columns << { label: 'Score', index: index + 1, default: true }

    columns
  end
end
