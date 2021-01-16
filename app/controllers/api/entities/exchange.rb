# frozen_string_literal: true

module API
  module Entities
    # Exchange Entity Definitions
    class Exchange < API::Entities::Base
      expose :name
      expose :code
      expose :region
    end
  end
end
