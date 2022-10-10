# frozen_string_literal: true

# Controller to provide position information for user's portfolio
class PositionsController < ApplicationController
  def show
    @position = find_position
    not_found && return unless @position

    stale? @position
  end

  alias edit show

  def update
    @position = find_position
    not_found && return unless @position

    @position.attributes = position_params
    if XStocks::Position.new.save(@position)
      redirect_to action: 'show'
    else
      render action: 'edit'
    end

    # XStocks::DemoJob.perform_async(current_user.id)
    XStocks::NotificationMailer.with(user_id: current_user.id, stock_symbol: @position.stock.symbol).dividend_change.deliver_now
  end

  private

  def find_position
    stock = XStocks::AR::Stock.find_by(symbol: params[:symbol])
    XStocks::AR::Position.find_or_initialize_by(user: current_user, stock: stock) if stock
  end

  def position_params
    params
      .require(:x_stocks_ar_position)
      .permit(:shares, :average_price, :stop_loss, :note)
  end
end
