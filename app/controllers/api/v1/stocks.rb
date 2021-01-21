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
          XStocks::AR::Stock.order(:symbol).pluck([:symbol])
        end

        desc 'Returns company information.',
             success: [
               { code: 200, model: API::Entities::Stock }
             ],
             failure: [
               { code: 401, message: 'Unauthorized' },
               { code: 404, message: 'Unknown Symbol' }
             ]
        params do
          requires :symbol, type: String, desc: 'Stock symbol for the report. Example: AAPL'
        end
        get ':symbol/company' do
          stock = XStocks::AR::Stock.find_by(symbol: params[:symbol])
          error!('Unknown Symbol', 404) unless stock
          present stock, with: API::Entities::Stock, type: :company
        end

        desc 'Returns stock information.',
             success: [
               { code: 200, model: API::Entities::Stock }
             ],
             failure: [
               { code: 401, message: 'Unauthorized' },
               { code: 404, message: 'Unknown Symbol' }
             ]
        params do
          requires :symbol, type: String, desc: 'Stock symbol for the report. Example: AAPL'
        end
        get ':symbol/quote' do
          stock = XStocks::AR::Stock.find_by(symbol: params[:symbol])
          error!('Unknown Symbol', 404) unless stock
          begin
            Etl::Refresh::Finnhub.new.hourly_one_stock!(stock)
          rescue StandardError
            nil
          end
          present stock, with: API::Entities::Stock, type: :quote
        end

        desc 'Returns stock earnings information.',
             success: [
               { code: 200, model: API::Entities::Stock }
             ],
             failure: [
               { code: 401, message: 'Unauthorized' },
               { code: 404, message: 'Unknown Symbol' }
             ]
        params do
          requires :symbol, type: String, desc: 'Stock symbol for the report. Example: AAPL'
        end
        get ':symbol/earnings' do
          stock = XStocks::AR::Stock.find_by(symbol: params[:symbol])
          error!('Unknown Symbol', 404) unless stock
          present stock, with: API::Entities::Stock, type: :earnings
        end

        desc 'Returns stock dividends information.',
             success: [
               { code: 200, model: API::Entities::Stock }
             ],
             failure: [
               { code: 401, message: 'Unauthorized' },
               { code: 404, message: 'Unknown Symbol' }
             ]
        params do
          requires :symbol, type: String, desc: 'Stock symbol for the report Ex: AAPL'
        end
        get ':symbol/dividends' do
          stock = XStocks::AR::Stock.find_by(symbol: params[:symbol])
          error!('Unknown Symbol', 404) unless stock
          present stock, with: API::Entities::Stock, type: :dividends
        end

        desc 'Returns stock recommendations.',
             success: [
               { code: 200, model: API::Entities::Stock }
             ],
             failure: [
               { code: 401, message: 'Unauthorized' },
               { code: 404, message: 'Unknown Symbol' }
             ]
        params do
          requires :symbol, type: String, desc: 'Stock symbol for the report Ex: AAPL'
        end
        get ':symbol/recommendations' do
          stock = XStocks::AR::Stock.find_by(symbol: params[:symbol])
          error!('Unknown Symbol', 404) unless stock
          present stock, with: API::Entities::Stock, type: :recommendations
        end
      end
    end
  end
end
