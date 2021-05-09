# frozen_string_literal: true

module XStocks
  module Jobs
    # CompanyAll Job
    class CompanyAll < Base
      def name
        'Update company information'
      end

      def tags
        ['Finnhub']
      end

      def perform(&block)
        lock do |logger|
          Etl::Refresh::Finnhub.new(logger).company_all_stocks(&block)
        end
      end

      def interval
        7.days
      end

      def schedule
        'Weekly'
      end
    end
  end
end
