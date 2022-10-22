# frozen_string_literal: true

module Etl
  module Transform
    # Transforms data extracted from VettaFi (etfdb.com)
    class VettaFi
      def etf_data(stock, attributes)
        return if attributes.blank?

        stock.attributes = attributes
        stock.save
      end
    end
  end
end
