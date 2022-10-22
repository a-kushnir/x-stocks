# frozen_string_literal: true

module Etl
  module Refresh
    # Extracts and transforms data from finnhub.io
    class VettaFiEtf < Base
      def all_etf_stocks
        loader = Etl::Extract::DataLoader.new(logger)

        each_stock_with_message do |stock, message|
          yield message if block_given?
          attributes = Etl::Extract::VettaFi.new(loader).etf_data(stock)
          Etl::Transform::VettaFi.new.etf_data(stock, attributes)
        end

        yield completed_message if block_given?
      end
    end
  end
end
