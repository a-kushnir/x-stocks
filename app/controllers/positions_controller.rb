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

    columns << {label: 'Shares', index: index = 1, default: true}
    columns << {label: 'Average Price', index: index += 1, default: true}
    columns << {label: 'Market Price', index: index += 1, default: true}
    columns << {label: 'Total Cost', index: index += 1, default: true}
    columns << {label: 'Market Value', index: index += 1, default: true}
    columns << {label: 'Gain/Loss', index: index += 1, default: true}
    columns << {label: 'Gain/Loss %', index: index += 1, default: true}
    columns << {label: 'Annual Dividend', index: index += 1, default: true}
    columns << {label: 'Diversity %', index: index += 1, default: true}

    columns << {label: 'Price', index: index += 1}
    columns << {label: 'Change', index: index += 1}
    columns << {label: 'Change %', index: index += 1}
    columns << {label: 'Fair Value', index: index += 1}
    columns << {label: 'Est. Annual Div.', index: index += 1}
    columns << {label: 'Est. Field %', index: index += 1}
    columns << {label: 'Payout %', index: index += 1}
    columns << {label: 'Yahoo Rec.', index: index += 1}
    columns << {label: 'Finnhub Rec.', index: index += 1}
    columns << {label: 'Div. Safety', index: index += 1}
    columns << {label: 'Ex Date', index: index += 1}
    columns << {label: 'Score', index: index + 1}

    columns
  end
end
