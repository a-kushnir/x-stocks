module API
  module V1
    class Positions < Grape::API
      include API::V1::Defaults

      namespace :positions do

        desc 'Returns all stock positions.'
        get do
          relation = Position.where(user: current_user).where.not(shares: nil)
          positions = relation.all
          market_value = relation.sum(:market_value)
          present positions, with: API::Entities::Position, type: :details, market_value: market_value
        end

        desc 'Returns stock position.'
        params do
          requires :symbol, type: String, desc: 'Stock symbol for the report Ex: AAPL'
        end
        get ':symbol' do
          stock = Stock.find_by(symbol: params[:symbol])
          error!('Unknown Symbol', 404) unless stock
          Etl::Refresh::Finnhub.new.hourly_one_stock!(stock) rescue nil
          relation = Position.where(user: current_user).where.not(shares: nil)
          position = relation.where(stock_id: stock.id).first
          error!('Unknown Symbol', 404) unless position
          market_value = relation.sum(:market_value)
          present position, with: API::Entities::Position, type: :details, market_value: market_value
        end
      end

        desc 'Returns all stock position summary.'
        get 'summary' do
          summary = OpenStruct.new(total_cost: 0, market_value: 0, gain_loss: 0, gain_loss_pct: 0, est_annual_income: 0)

          Position.where(user: current_user).where.not(shares: nil).all.each do |position|
            summary.total_cost += position.total_cost if position.total_cost
            summary.market_value += position.market_value if position.market_value
            summary.gain_loss += position.gain_loss if position.gain_loss
            summary.est_annual_income += position.est_annual_income if position.est_annual_income
          end
          summary.gain_loss_pct = (summary.gain_loss / summary.total_cost).round(4) * 100 rescue nil

          present summary, with: API::Entities::Position, type: :summary
        end

    end
  end
end
