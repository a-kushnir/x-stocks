module Etl
  module Refresh
    class FearNGreed

      def image_url(logger = nil)
        Config.cached(:fear_n_greed_image_url, 1.hour) do
          extractor = Etl::Extract::FearNGreed.new(logger: logger)
          source_image_url = extractor.image_url

          stored_image_url = '/img/fear-and-greed.png'
          unless source_image_url.blank?
            path = "#{Rails.root}/public#{stored_image_url}"
            extractor.download(path, source_image_url)
          end

          stored_image_url
        end
      end

    end
  end
end
