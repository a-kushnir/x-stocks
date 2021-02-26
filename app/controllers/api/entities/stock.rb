# frozen_string_literal: true

module API
  module Entities
    # Stock Entity Definitions
    class Stock < API::Entities::Base
      expose :symbol, documentation: { required: true }
      expose(:exchange) { |model, _| model.exchange&.code }
    end
  end
end
