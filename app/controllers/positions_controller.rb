class PositionsController < ApplicationController
  def index
    @positions = Position
      .where(user: current_user)
      .where.not(shares: nil)
      .all

    @columns = columns

    @page_title = 'My Positions'
    @page_menu_item = :positions

    respond_to do |format|
      format.html { }
      format.xlsx { generate_xlsx }
    end
  end

  def update
    @position = find_position
    not_found && return unless @position

    if @position.update(position_params)
      @position.destroy if @position.shares.blank? && @position.note.blank?
      render partial: 'show', layout: nil
    else
      render partial: 'edit', layout: nil
    end
  rescue Exception => error
    internal_error(error, layout: nil)
  end

  private

  def find_position
    stock = Stock.find_by(symbol: params[:id])
    Position.find_or_initialize_by(user: current_user, stock: stock) if stock
  end

  def position_params
    params.require(:position).permit(:shares, :average_price, :note)
  end

  def generate_xlsx
    send_tmp_file('Positions.xlsx') do |file_name|
      Xlsx::Positions.new.generate(file_name, @positions)
    end
  end

  def columns
    columns = []
    columns << {label: 'Shares', index: 1}
    columns << {label: 'Average Price', index: 2}
    columns << {label: 'Market Price', index: 3}
    columns << {label: 'Total Cost', index: 4}
    columns << {label: 'Market Value', index: 5}
    columns << {label: 'Gain/Loss', index: 6}
    columns << {label: 'Gain/Loss %', index: 7}
    columns << {label: 'Annual Dividend', index: 8}
    columns << {label: 'Diversity %', index: 9}
    columns
  end
end
