# frozen_string_literal: true

module XStocks
  class Stock
    # Stock AR Updaters Business Model
    module ARUpdaters
      def save
        prepare_symbol
        calculate_meta_score
        calculate_stock_prices
        calculate_stock_dividends
        return unless ar_stock.save

        position = XStocks::Position.new
        position.calculate_stock_prices(ar_stock)
        position.calculate_stock_dividends(ar_stock)
        position.update_timestamp(ar_stock)
        true
      end

      def save!
        save || raise(ActiveRecord::RecordNotSaved)
      end

      def destroyable?
        !ar_stock.positions.exists?
      end

      def destroy
        return unless destroyable?

        ar_stock.destroy
      end

      private

      def prepare_symbol
        ar_stock.symbol = ar_stock.symbol.strip.upcase
      end
    end
  end
end
