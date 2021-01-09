# frozen_string_literal: true

module Etl
  module Extract
    class FearNGreed < Base
      BASE_URL = 'https://money.cnn.com/data/fear-and-greed/'
      REGEX = /id="needleChart[^<]+image:url\(&#39;([^<]+)&#39;\);/.freeze

      def image_url
        text = get_text(BASE_URL)
        text.scan(REGEX).first.first
      end
    end
  end
end
