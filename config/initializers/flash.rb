# frozen_string_literal: true

require 'action_dispatch/middleware/flash'

module ActionDispatch
  class Flash
    module FlashHashOverride
      def []=(k, v)
        v = CGI.escapeHTML(v) unless v&.html_safe?
        super
      end
    end

    FlashHash.prepend(FlashHashOverride)
  end
end
