# frozen_string_literal: true

require 'action_view/helpers/url_helper'

module DataTable
  module Formats
    # Formats value as a string
    class StockLink
      include ActionView::Helpers::UrlHelper

      def align
        :left
      end

      def format(value)
        link_to(value, main_app.stock_path(value), class: 'w-full', target: '_top') if value
      end

      def style(_value); end

      private

      def main_app
        Rails.application.routes.url_helpers
      end
    end
  end
end
