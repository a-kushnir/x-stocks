# frozen_string_literal: true

require 'tzinfo'

module Etl
  module Refresh
    # Extracts and transforms data from money.cnn.com
    class FearNGreed
      BASE_URL = 'https://production.dataviz.cnn.io/index/fearandgreed/graphdata'
      EXPIRES_IN = 1.hour

      def data(logger: nil)
        value =
          XStocks::Config.new.cached(:fear_n_greed_data, EXPIRES_IN) do
            loader = Etl::Extract::DataLoader.new(logger)
            loader.get_text(BASE_URL)
          end
        JSON.parse(value, symbolize_names: true)
      rescue Exception => e
        logger&.log_error(e)
      end
    end
  end
end
