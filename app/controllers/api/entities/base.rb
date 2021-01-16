# frozen_string_literal: true

module API
  module Entities
    # Base Entity Definitions
    class Base < Grape::Entity
      format_with(:float) do |number|
        number ? number.to_f : nil
      end

      format_with(:bool) do |value|
        !!value
      end
    end
  end
end
