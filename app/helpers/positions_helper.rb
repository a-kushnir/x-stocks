module PositionsHelper

  def position_path(position)
    "/positions/#{URI.escape(position.stock.symbol)}"
  end

  def edit_position_path(position)
    "/positions/#{URI.escape(position.stock.symbol)}/edit"
  end
end
