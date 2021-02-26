# frozen_string_literal: true

module API
  module Entities
    # Exchange Entity Definitions
    class Exchange < API::Entities::Base
      expose :name, documentation: { required: true }
      expose :code, documentation: { required: true }
      expose :region, documentation: { required: true }
    end
  end
end
