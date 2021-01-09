# frozen_string_literal: true

module Etl
  module Refresh
    class FearNGreed
      def image_url(logger = nil)
        stored_image_url = '/img/fear-and-greed.png'
        stored_image_path = "#{Rails.root}/public#{stored_image_url}"

        begin
          expires_in = File.exist?(stored_image_path) ? 1.hour : nil
          Config.cached(:fear_n_greed_image_url, expires_in) do
            extractor = Etl::Extract::FearNGreed.new(logger: logger)
            source_image_url = extractor.image_url

            extractor.download(stored_image_path, source_image_url) unless source_image_url.blank?
          end
        rescue Exception => e
          logger&.log_error(e)
        end

        stored_image_url
      end
    end
  end
end
