# frozen_string_literal: true

module Etl
  module Extract
    # Extracts data from money.cnn.com
    class FearNGreed
      BASE_URL = 'https://money.cnn.com/data/fear-and-greed/'
      REGEX = /id="needleChart[^<]+image:url\(&#39;([^<]+)&#39;\);/.freeze

      def initialize(data_loader)
        @data_loader = data_loader
      end

      def image_url
        text = @data_loader.get_text(BASE_URL)
        text.scan(REGEX).first.first
      end

      private

      attr_reader :data_loader
    end
  end
end
