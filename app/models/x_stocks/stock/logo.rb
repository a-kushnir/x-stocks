# frozen_string_literal: true

module XStocks
  class Stock
    # Stock Logo Business Model
    module Logo
      def store_logo(content)
        return ar_stock.logo if content.blank?

        File.open(logo_path, 'wb') { |file| file << content }

        ar_stock.logo = logo_url
      end

      def delete_logo
        File.delete(logo_path) if File.exist?(logo_path)
      end

      private

      def logo_url
        "/img/logos/#{ar_stock.symbol}.png"
      end

      def logo_path
        "#{Rails.root}/public#{logo_url}"
      end
    end
  end
end
