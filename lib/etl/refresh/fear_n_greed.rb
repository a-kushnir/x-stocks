# frozen_string_literal: true

module Etl
  module Refresh
    # Extracts and transforms data from money.cnn.com
    class FearNGreed
      def image_path(logger: nil)
        stored_image_url = '/img/fear-and-greed.png'
        stored_image_path = "#{Rails.root}/public#{stored_image_url}"

        begin
          expires_in = File.exist?(stored_image_path) ? 1.hour : nil
          XStocks::Config.new.cached(:fear_n_greed_image_url, expires_in) do
            data_loader = Etl::Extract::DataLoader.new(logger)
            extractor = Etl::Extract::FearNGreed.new(data_loader)
            source_image_url = extractor.image_url

            if source_image_url.present?
              loader = Etl::Extract::DataLoader.new(logger)
              loader.download(stored_image_path, source_image_url)
            end
          end
        rescue Exception => e
          logger&.log_error(e)
        end

        stored_image_path
      end
    end
  end
end
