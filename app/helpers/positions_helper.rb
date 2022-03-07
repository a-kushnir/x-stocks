# frozen_string_literal: true

# Helper methods for PositionsController
module PositionsHelper
  def format_if_valid(model, attribute)
    if model.errors[attribute].empty?
      yield model.send(attribute)
    else
      model.send("#{attribute}_before_type_cast")
    end
  end
end
