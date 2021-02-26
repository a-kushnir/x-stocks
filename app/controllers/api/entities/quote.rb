# frozen_string_literal: true

module API
  module Entities
    # Stock Quote Entity Definitions
    class Quote < API::Entities::Base
      expose :symbol, documentation: { required: true }
      expose(:exchange) { |model, _| model.exchange&.code }

      with_options(format_with: :float, documentation: { type: :float }) do
        expose :current_price
        expose :prev_close_price
        expose :open_price
        expose :price_change
        expose :price_change_pct
        expose :day_low_price
        expose :day_high_price
        expose :week_52_high
        expose :week_52_high_date, format_with: nil, documentation: { type: :string }
        expose :week_52_low
        expose :week_52_low_date, format_with: nil, documentation: { type: :string }
      end
    end
  end
end
