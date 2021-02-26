# frozen_string_literal: true

module API
  module Entities
    # Stock Company Entity Definitions
    class Company < API::Entities::Base
      expose :symbol, documentation: { required: true }
      expose(:exchange) { |model, _| model.exchange&.code }

      expose :company_name
      expose :industry
      expose :website
      expose :description
      expose :ceo
      expose :security_name
      expose :issue_type
      expose :sector
      expose :primary_sic_code, documentation: { type: :integer }
      expose :employees, documentation: { type: :integer }
      expose :address
      expose :address2
      expose :state
      expose :city
      expose :zip
      expose :country
      expose :phone
      expose :ipo
      expose :logo
      expose :peers, documentation: { type: :string, is_array: true }
      expose :outstanding_shares, documentation: { type: :integer }
      expose :market_capitalization, documentation: { type: :integer }
      expose :sp500, format_with: :bool, documentation: { type: :boolean }
      expose :nasdaq100, format_with: :bool, documentation: { type: :boolean }
      expose :dowjones, format_with: :bool, documentation: { type: :boolean }
    end
  end
end
