# frozen_string_literal: true

module XStocks
  module Jobs
    # YahooScanUrl Job
    class YahooScanUrl < Base
      def name
        'Scan Stock List URL'
      end

      def tags
        ['Yahoo']
      end

      def perform(url:, &block)
        lock do |logger|
          Etl::Refresh::Yahoo.new(logger).scan_url(url, &block)
        end
      end

      def arguments
        { url: text_field_tag(placeholder: 'URL') }
      end
    end
  end
end
