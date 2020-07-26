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

        if stock.save

          if number_or_nil(node['consective_year_of_growth']).is_a?(Numeric)
            tags = []

            if stock.dividend_growth_years >= 10
              tags << 'Dividend Achiever'
            end
            if stock.dividend_growth_years >= 10 && stock.dividend_growth_years < 25
              tags << 'Dividend Contender'
            end
            if stock.dividend_growth_years >= 25
              tags << 'Dividend Champion'
            end

            ::Tag.batch_update(stock, :dividend_tag, tags)
          end

          if node['dars_overall'].present?
            tags = []
            tags << 'Safe Dividends' if stock.dividend_rating && stock.dividend_rating >= 4.0
            ::Tag.batch_update(stock, :safe_dividend_tag, tags)
          end

          if stock.dividend_growth_3y.to_f >= 5.0 || stock.dividend_growth_5y.to_f >= 5.0
            tags = []
            tags << 'High Dividend Growth'
            ::Tag.batch_update(stock, :dividend_growth_tag, tags)
          end

        end
      end

    end
  end
end
