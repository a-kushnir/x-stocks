# frozen_string_literal: true

module XStocks
  module Jobs
    # VettaFiEtfAll Job
    class VettaFiEtfAll < Base
      def name
        'Update ETF information'
      end

      def tags
        ['VettaFi']
      end

      def perform(&block)
        lock do |logger|
          Etl::Refresh::VettaFiEtf.new(logger).all_etf_stocks(&block)
        end
      end
    end
  end
end
