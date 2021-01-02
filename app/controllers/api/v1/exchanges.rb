module API
  module V1
    class Exchanges < Grape::API
      include API::V1::Defaults

      namespace :exchanges do

        desc 'Returns available stock exchanges.'
        get do
          exchanges = Exchange.all
          present exchanges, with: API::Entities::Exchange
        end

        desc 'Returns stock exchange information.'
        params do
          requires :code, type: String, desc: 'Stock exchange code for the report Ex: NYSE'
        end
        get ':code' do
          exchange = Exchange.find_by(code: params[:code]&.upcase)
          present exchange, with: API::Entities::Exchange
        end
      end

    end
  end
end
