# frozen_string_literal: true

require 'action_view/helpers/form_helper'

module ActionView
  module Helpers
    # Contains standard set of helper methods for form building
    class FormBuilder
      def error_message_for(method)
        errors = object.errors[method]
        label method, errors.join(', '), class: 'error-message' if errors.present?
      end
    end
  end
end
