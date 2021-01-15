# frozen_string_literal: true

module Etl
  module Transform
    class Dividend
      def data(stock, json)
        json ||= {}
        node = json.dig('thead', 0)
        return if node.blank?

        stock.dividend_rating = number_or_nil(node['dars_overall'])
        stock.dividend_growth_3y = number_or_nil(node['growth_over_years'])
        stock.dividend_growth_years = number_or_nil(node['consective_year_of_growth'])

        stock.save
      end

      private

      def number?(value)
        value =~ /^[\-+]?[0-9]*\.?[0-9]*$/i
      end

      def number_or_nil(value)
        number?(value) ? value.to_d : nil
      end
    end
  end
end
