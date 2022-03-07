# frozen_string_literal: true

require 'action_view/helpers/tag_helper'

module XStocks
  module Charts
    # Chart Tag
    class ChartTag
      extend ActionView::Helpers::TagHelper

      def self.for(type, width:, height:, data:)
        tag(:canvas, width: width, height: height, data: { controller: "#{type}-chart", "#{type}-chart-value" => data })
      end
    end
  end
end
