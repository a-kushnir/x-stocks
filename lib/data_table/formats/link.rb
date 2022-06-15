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

        name, url = value
        link_to(name, url, class: 'w-full', target: '_top')
      end

      def style(_value); end
    end
  end
end
