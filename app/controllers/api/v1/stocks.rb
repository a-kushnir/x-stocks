module API
  module V1
    class Stocks < Grape::API
      include API::V1::Defaults

      namespace :stocks do

        desc 'Returns available stock symbols.'
        get do
          Stock.order(:symbol).pluck([:symbol])
        end

        desc 'Returns stock information.'
        params do
          requires :symbol, type: String, desc: 'Stock symbol for the report Ex: AAPL'
        end
        get ':symbol' do
          stock = Stock.find_by(symbol: params[:symbol])
          error!('Unknown Symbol', 404) unless stock
          stock.attributes
        end
      end

    end
  end
end
