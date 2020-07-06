module PositionsHelper

  def position_path(position)
    "/positions/#{position.stock.symbol}"
  end

  def edit_position_path(position)
    "/positions/#{position.stock.symbol}/edit"
  end
end
