class PositionsController < ApplicationController
  def index
    @positions = Position.where(user: current_user).all

    @page_title = 'My Positions'
    @page_menu_item = :positions
  end

  def update
    @position = find_position
    not_found && return unless @position
    # TODO Destroy

    if @position.update(position_params)
      render action: 'show', layout: nil
    else
      render action: 'edit', layout: nil
    end
  end

  private

  def find_position
    stock = Stock.find_by(symbol: params[:id])
    Position.find_or_initialize_by(user: current_user, stock: stock) if stock
  end

  def position_params
    params.require(:position).permit(:shares, :average_price, :note)
  end
end
