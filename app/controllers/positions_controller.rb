class PositionsController < ApplicationController
  include PositionsHelper

  before_action :authenticate_user!

  def index
    @page_title = 'My Positions'
    @positions = positions.all
  end

  def show
    @position = find_position
    not_found && return unless @position

    set_page_title
  end

  def new
    @position = new_position
    set_page_title
  end

  def create
    @position = new_position
    @position.update(position_params)
    if @position.save
      flash[:notice] = "#{@position} position created"
      redirect_to position_path(@position)
    else
      set_page_title
      render action: 'new'
    end
  end

  def edit
    @position = find_position
    not_found && return unless @position

    set_page_title
  end

  def update
    @position = find_position
    not_found && return unless @position

    if @position.update(position_params)
      flash[:notice] = "#{@position} position updated"
      redirect_to position_path(@position)
    else
      set_page_title
      render action: 'edit'
    end
  end

  def destroy
    @position = find_position
    not_found && return unless @position

    @position.delete
    flash[:notice] = "#{@position} position deleted"
    redirect_to positions_path
  end

  private

  def set_page_title
    @page_title =
      if @position.new_record?
        'New Position'
      elsif @position.stock.company
        "#{@position.stock.company.company_name} (#{@position.stock.symbol})"
      else
        @position.stock.symbol
      end
  end

  def new_position
    Position.new(user_id: current_user.id)
  end

  def positions
    Position.where(user_id: current_user.id)
  end

  def find_position
    stock = Stock.find_by(symbol: params[:id])
    positions.find_by(stock_id: stock.id) if stock
  end

  def position_params
    params.require(:position).permit(:stock_id, :shares, :average_cost)
  end
end
