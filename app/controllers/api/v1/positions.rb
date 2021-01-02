module API
  module V1
    class Positions < Grape::API
      include API::V1::Defaults

      namespace :positions do

        desc 'Returns all stock position.'
        get do
          positions = Position.where(user: current_user).where.not(shares: nil).all
          present positions, with: API::Entities::Position
        end

        desc 'Returns stock position.'
        params do
          requires :symbol, type: String, desc: 'Stock symbol for the report Ex: AAPL'
        end
        get ':symbol' do
          stock = Stock.find_by(symbol: params[:symbol])
          error!('Unknown Symbol', 404) unless stock
          position = Position.where(user: current_user).where.not(shares: nil).where(stock_id: stock.id).first
          error!('Unknown Symbol', 404) unless position
          present position, with: API::Entities::Position
        end
      end

    end
  end
end
