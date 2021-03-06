# frozen_string_literal: true

module API
  module V1
    # Default V1 API settings
    module Defaults
      extend ActiveSupport::Concern

      included do
        version 'v1', using: :path

        helpers do
          def current_user
            token = params['token'] || headers['X-Stocks-Token']
            @current_user ||= XStocks::AR::User.find_by_api_key(token) if token.present?
          end

          def authorize!
            error!('Unauthorized', 401) unless current_user
          end
        end

        before do
          header 'Access-Control-Allow-Origin', '*'
          authorize!
        end
      end
    end
  end
end
