module Etl
  module Transform
    class Dividend < Base

      def data(stock, json)
        json ||= {}
        node = json.dig('thead', 0)
        return if node.blank?

        stock.dividend_rating = number_or_nil(node['dars_overall'])
        stock.dividend_growth_3y = number_or_nil(node['growth_over_years'])
        stock.dividend_growth_years = number_or_nil(node['consective_year_of_growth'])

        stock.save

      ::Tag.batch_update(stock, :dividend_tag, [])
      ::Tag.batch_update(stock, :safe_dividend_tag, [])
      ::Tag.batch_update(stock, :dividend_growth_tag, [])
      end

    end
  end
end
