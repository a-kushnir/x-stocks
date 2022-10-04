# frozen_string_literal: true

module API
  module V1
    # Stocks API endpoints
    class Stocks < Grape::API
      include API::V1::Defaults

      namespace :stocks do
        desc 'Returns available stock symbols.',
             is_array: true,
             success: [
               { code: 200, model: API::Entities::Stock }
             ],
             failure: [
               { code: 401, message: 'Unauthorized' }
             ]
        get do
          stocks = XStocks::AR::Stock.order(:symbol).select(:symbol, :exchange_id).all.to_a
          present stocks, with: API::Entities::Stock
        end

        desc 'Returns company information.',
             success: [
               { code: 200, model: API::Entities::Company }
             ],
             failure: [
               { code: 401, message: 'Unauthorized' },
               { code: 404, message: 'Unknown Symbol' }
             ]
        params do
          requires :symbol, type: String, desc: 'Stock symbol for the report. Example: AAPL'
        end
        get ':symbol/company' do
          stock = XStocks::Stock.find_by_symbol(params[:symbol])
          error!('Unknown Symbol', 404) unless stock
          present stock, with: API::Entities::Company
        end

        desc 'Returns quote information.',
             success: [
               { code: 200, model: API::Entities::Quote }
             ],
             failure: [
               { code: 401, message: 'Unauthorized' },
               { code: 404, message: 'Unknown Symbol' }
             ]
        params do
          requires :symbol, type: String, desc: 'Stock symbol for the report. Example: AAPL'
        end
        get ':symbol/quote' do
          stock = XStocks::Stock.find_by_symbol(params[:symbol])
          error!('Unknown Symbol', 404) unless stock
          begin
            Etl::Refresh::Finnhub.new(nil).hourly_one_stock!(stock)
          rescue StandardError
            nil
          end
          present stock, with: API::Entities::Quote
        end

        desc 'Returns stock earnings information.',
             success: [
               { code: 200, model: API::Entities::Earnings }
             ],
             failure: [
               { code: 401, message: 'Unauthorized' },
               { code: 404, message: 'Unknown Symbol' }
             ]
        params do
          requires :symbol, type: String, desc: 'Stock symbol for the report. Example: AAPL'
        end
        get ':symbol/earnings' do
          stock = XStocks::Stock.find_by_symbol(params[:symbol])
          error!('Unknown Symbol', 404) unless stock
          present stock, with: API::Entities::Earnings, type: :earnings
        end

        desc 'Returns stock dividends information.',
             success: [
               { code: 200, model: API::Entities::Dividends }
             ],
             failure: [
               { code: 401, message: 'Unauthorized' },
               { code: 404, message: 'Unknown Symbol' }
             ]
        params do
          requires :symbol, type: String, desc: 'Stock symbol for the report Ex: AAPL'
        end
        get ':symbol/dividends' do
          stock = XStocks::Stock.find_by_symbol(params[:symbol])
          error!('Unknown Symbol', 404) unless stock
          present stock, with: API::Entities::Dividends
        end

        desc 'Returns stock recommendations.',
             success: [
               { code: 200, model: API::Entities::Recommendation }
             ],
             failure: [
               { code: 401, message: 'Unauthorized' },
               { code: 404, message: 'Unknown Symbol' }
             ]
        params do
          requires :symbol, type: String, desc: 'Stock symbol for the report Ex: AAPL'
        end
        get ':symbol/recommendations' do
          stock = XStocks::Stock.find_by_symbol(params[:symbol])
          error!('Unknown Symbol', 404) unless stock
          present stock, with: API::Entities::Recommendation
        end
      end
    end
  end
end
