# frozen_string_literal: true

require 'action_dispatch/middleware/flash'

module ActionDispatch
  # The flash provides a way to pass temporary primitive-types (String, Array, Hash) between actions. Anything you place in the flash will be exposed
  # to the very next action and then cleared out. This is a great way of doing notices and alerts, such as a create
  # action that sets <tt>flash[:notice] = "Post successfully created"</tt> before redirecting to a display action that can
  # then expose the flash to its template. Actually, that exposure is automatically done.
  class Flash
    # Raw HTML native support
    module FlashHashOverride
      def []=(key, value)
        value = CGI.escapeHTML(value) unless value&.html_safe?
        super
      end
    end

    FlashHash.prepend(FlashHashOverride)
  end
end
