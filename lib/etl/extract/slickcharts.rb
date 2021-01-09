# frozen_string_literal: true

module Etl
  module Extract
    class Slickcharts < Base
      BASE_URL = 'https://www.slickcharts.com'

      def sp500
        text_to_list(get_text(sp500_url))
      end

      def nasdaq100
        text_to_list(get_text(nasdaq100_url))
      end

      def dowjones
        text_to_list(get_text(dowjones_url))
      end

      private

      def sp500_url
        "#{BASE_URL}/sp500"
      end

      def nasdaq100_url
        "#{BASE_URL}/nasdaq100"
      end

      def dowjones_url
        "#{BASE_URL}/dowjones"
      end

      def text_to_list(value)
        matches = value.scan(%r{<td><a href="/symbol/(.+)">(.+)</a></td>}i)
        hash = {}
        matches.each do |match|
          hash[match.first] = true
        end
        hash.keys
      end
    end
  end
end
