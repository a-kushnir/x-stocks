# frozen_string_literal: true

module XStocks
  module Jobs
    # YahooScanFile Job
    class YahooScanFile < Base
      def name
        'Scan Stock List File'
      end

      def tags
        ['Yahoo']
      end

      def perform(file:, &block)
        lock do |logger|
          Etl::Refresh::Yahoo.new(logger).scan_file(file.read, &block)
        end
      end

      def arguments
        [:file]
      end
    end
  end
end
