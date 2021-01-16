# frozen_string_literal: true

module PositionsHelper
  def position_path(position)
    "/positions/#{CGI.escape(position.stock.symbol)}"
  end

  def edit_position_path(position)
    "/positions/#{CGI.escape(position.stock.symbol)}/edit"
  end

  def format_if_valid(model, attribute)
    if model.errors[attribute].empty?
      yield model.send(attribute)
    else
      model.send("#{attribute}_before_type_cast")
    end
  end
end
