# frozen_string_literal: true

module API
  module Entities
    # Stock Recommendation Entity Definitions
    class Recommendation < API::Entities::Base
      expose :symbol, documentation: { required: true }
      expose(:exchange) { |model, _| model.exchange&.code }

      expose :yahoo_beta, format_with: :float, documentation: { type: :float }
      expose :yahoo_rec, format_with: :float, documentation: { type: :float }
      expose :yahoo_rec_details, documentation: { type: :object }
      expose :yahoo_discount, documentation: { type: :number }
      expose :yahoo_price_target, documentation: { type: :object }
      expose :finnhub_beta, format_with: :float, documentation: { type: :float }
      expose :finnhub_price_target, documentation: { type: :object }
      expose :finnhub_rec, format_with: :float, documentation: { type: :float }
      expose :finnhub_rec_details, documentation: { type: :object }
      expose :metascore, documentation: { type: :number }
      expose :metascore_details, documentation: { type: :object }
    end
  end
end
