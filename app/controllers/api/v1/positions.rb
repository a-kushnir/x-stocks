# frozen_string_literal: true

module API
  module V1
    # Positions API endpoints
    class Positions < Grape::API
      include API::V1::Defaults

      namespace :positions do
        desc 'Returns whole portfolio information',
             success: [
               { code: 200, model: API::Entities::Portfolio }
             ],
             failure: [
               { code: 401, message: 'Unauthorized' }
             ]
        get do
          portfolio = Struct.new(:total_cost, :market_value, :gain_loss, :gain_loss_pct, :est_annual_income, :positions).new(0, 0, 0, 0, 0, [])

          positions = XStocks::AR::Position.where(user: current_user).where.not(shares: nil).all
          positions.each do |position|
            portfolio.total_cost += position.total_cost if position.total_cost
            portfolio.market_value += position.market_value if position.market_value
            portfolio.gain_loss += position.gain_loss if position.gain_loss
            portfolio.est_annual_income += position.est_annual_income if position.est_annual_income
            portfolio.positions << position
          end
          portfolio.gain_loss_pct = begin
            (portfolio.gain_loss / portfolio.total_cost).round(4) * 100
          rescue StandardError
            nil
          end

          present portfolio, with: API::Entities::Portfolio, market_value: portfolio.market_value
        end

        desc 'Returns position for specified stock',
             success: [
               { code: 200, model: API::Entities::Position }
             ],
             failure: [
               { code: 401, message: 'Unauthorized' },
               { code: 404, message: 'Unknown Symbol' }
             ]
        params do
          requires :symbol, type: String, desc: 'Stock symbol for the report. Example: AAPL'
        end
        get ':symbol' do
          stock = XStocks::AR::Stock.find_by(symbol: params[:symbol])
          error!('Unknown Symbol', 404) unless stock
          begin
            Etl::Refresh::Finnhub.new.hourly_one_stock!(stock)
          rescue StandardError
            nil
          end
          relation = XStocks::AR::Position.where(user: current_user).where.not(shares: nil)
          position = relation.where(stock_id: stock.id).first
          error!('Unknown Symbol', 404) unless position
          market_value = relation.sum(:market_value)
          present position, with: API::Entities::Position, market_value: market_value
        end
      end
    end
  end
end
