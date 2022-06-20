# frozen_string_literal: true

require 'action_view/record_identifier'

module ActionView
  module RecordIdentifier
    # Overrides dom_id to use hashid instead of id if available
    module Override
      protected

      # :reek:ManualDispatch
      def record_key_for_dom_id(record)
        model = convert_to_model(record)
        key = model.respond_to?(:hashid) && model.hashid
        key || super
      end
    end
  end
end

ActiveSupport.on_load(:action_view) do
  # Prepends module methods to use dom_id after include ActionView::RecordIdentifier
  ActionView::RecordIdentifier.prepend(ActionView::RecordIdentifier::Override)
  # Extends module methods to use dom_id as ActionView::RecordIdentifier.dom_id
  ActionView::RecordIdentifier.extend(ActionView::RecordIdentifier::Override)
  # Prepends helper methods
  prepend(ActionView::RecordIdentifier::Override)
end
