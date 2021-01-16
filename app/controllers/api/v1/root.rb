# frozen_string_literal: true

module API
  module V1
    # Root V1 API class
    module Root
      extend ActiveSupport::Concern

      included do
        mount API::V1::Exchanges
        mount API::V1::Stocks
        mount API::V1::Positions

        add_swagger_documentation \
          info: { title: 'xStocks API' },
          mount_path: '/v1/swagger_doc',
          base_path: '/api/v1',
          doc_version: '1.0.4',
          add_version: false,
          hide_documentation_path: true,
          models: [
            API::Entities::Exchange,
            API::Entities::Position,
            API::Entities::Stock,
            API::Entities::Portfolio
          ],
          schemes: ['http'],
          security_definitions: {
            ApiKeyAuth: {
              type: 'apiKey',
              in: 'query',
              name: 'token'
            }
          },
          security: [
            {
              ApiKeyAuth: []
            }
          ]
      end
    end
  end
end
