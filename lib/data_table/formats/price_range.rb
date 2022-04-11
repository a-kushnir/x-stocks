# frozen_string_literal: true

require 'action_view/helpers/number_helper'

module DataTable
  module Formats
    # Formats value as a Price Range
    class PriceRange
      include ActionView::Helpers::NumberHelper

      def align
        :center
      end

      def format(value)
        return unless value

        min, max, current, change = value

        points = [current, current - change].sort
        progress1 = Math.inv_lerp(min, max, points[0]) * 100
        progress2 = Math.inv_lerp(min, max, points[1]) * 100 - progress1
        progress2 = 2 if progress2 < 2 # Min width is 2%
        css_class = change.negative? ? 'bg-danger' : 'bg-success'

        build do |html|
          html << '<div class="progress" style="height: 4px; min-width: 100px;">'
          html << "<div class='progress-bar' style='width: #{progress1}%; background-color: transparent;'></div>"
          html << "<div class='progress-bar #{css_class}' style='width: #{progress2}%'></div>"
          html << '</div>'
          html << '<span class="text-xs">'
          html << "<span class='float-left'>#{ number_to_currency(min, unit: '') }</span>"
          html << "<span class='float-right'>#{ number_to_currency(max, unit: '') }</span>"
          html << '</span>'
        end
      end

      def style(_value); end

      def build
        html = []
        yield html
        html.join.html_safe
      end
    end
  end
end
