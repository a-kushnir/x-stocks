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

            unless source_image_url.blank?
              extractor.download(stored_image_path, source_image_url)
            end
          end
        rescue Exception => error
          logger&.log_error(error)
        end

        stored_image_url
      end

    end
  end
end
