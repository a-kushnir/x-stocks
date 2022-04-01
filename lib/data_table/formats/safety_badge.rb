# frozen_string_literal: true

module DataTable
  module Formats
    # Formats value as a string
    class SafetyBadge
      def format(value)
        [value ? "<span class='badge badge-dark #{style((value * 20).to_i)}'>#{(value * 20).to_i}</span>".html_safe : nil, nil]
      end

      def style(value)
        if value.blank?
          nil
        elsif value > 80
          'rec-str-buy'
        elsif value > 60
          'rec-buy'
        elsif value > 40
          'rec-hold'
        elsif value > 20
          'rec-sell'
        else
          'rec-str-sell'
        end
      end
    end
  end
end
