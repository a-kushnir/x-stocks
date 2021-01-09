# frozen_string_literal: true

module API
  module V1
    class Exchanges < Grape::API
      include API::V1::Defaults

      namespace :exchanges do
        desc 'Returns available stock exchanges',
             is_array: true,
             success: [
               { code: 200, model: API::Entities::Exchange }
             ],
             failure: [
               { code: 401, message: 'Unauthorized' }
             ]
        get do
          exchanges = Exchange.all
          present exchanges, with: API::Entities::Exchange
        end

        desc 'Returns stock exchange information',
             success: [
               { code: 200, model: API::Entities::Exchange }
             ],
             failure: [
               { code: 401, message: 'Unauthorized' },
               { code: 404, message: 'Unknown Code' }
             ]
        params do
          requires :code, type: String, desc: 'Stock exchange code for the report. Example: NYSE'
        end
        get ':code' do
          exchange = Exchange.find_by(code: params[:code]&.upcase)
          present exchange, with: API::Entities::Exchange
        end
      end
    end
  end
end
