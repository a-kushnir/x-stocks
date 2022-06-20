# frozen_string_literal: true

module XStocks
  class Stock
    module Lists
      # Portfolio as a stock list
      class Portfolio
        TYPE = 'portfolio'

        def initialize(current_user)
          @current_user = current_user
        end

        def values
          [[t('positions.pages.portfolio'), TYPE]]
        end

        def stock_ids(_hashid)
          current_user.positions.pluck(:stock_id)
        end

        attr_reader :current_user

        delegate :t, to: I18n
      end
    end
  end
end
