# frozen_string_literal: true

require 'action_view/helpers/url_helper'

module DataTable
  module Formats
    # Formats value as a link
    class Link
      include ActionView::Helpers::UrlHelper

      def align
        :left
      end

      def format(value)
        return unless value

        name, url, options = value
        options = { class: 'w-full', target: '_top' }.merge(options || {})

        link_to(name, url, options)
      end

      def style(_value)
        'link'
      end
    end
  end
end
