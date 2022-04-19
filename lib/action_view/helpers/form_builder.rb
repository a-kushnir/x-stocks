# frozen_string_literal: true

module ActionView
  module Helpers
    class FormBuilder
      def error_message_for(method)
        errors = object.errors[method]
        label method, errors.join(', '), class: 'error-message' if errors.present?
      end
    end
  end
end
