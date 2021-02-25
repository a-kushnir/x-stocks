# frozen_string_literal: true

module XStocks
  class Stock
    # Stock Logo Business Model
    module Logo
      def store_file(stock, content)
        return stock.logo if content.blank?

        File.open(logo_path(stock), 'wb') { |file| file << content }

        stock.logo = logo_url(stock)
      end

      def delete_logo(stock)
        File.delete(logo_path(stock)) if File.exist?(logo_path(stock))
      end

      private

      def logo_url(stock)
        "/img/logos/#{stock.symbol}.png"
      end

      def logo_path(stock)
        "#{Rails.root}/public#{logo_url(stock)}"
      end
    end
  end
end
