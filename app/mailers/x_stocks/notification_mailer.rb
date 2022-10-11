# frozen_string_literal: true

module XStocks
  # Test Mailer
  class NotificationMailer < ApplicationMailer
    helper :application,
           :stocks

    def dividend_change
      user_id, stock_symbol = params.values_at(:user_id, :stock_symbol)

      @user = XStocks::AR::User.find_by(id: user_id)
      @stock = XStocks::Stock.new(XStocks::AR::Stock.find_by(symbol: stock_symbol))
      @position = XStocks::AR::Position.find_by(user_id: @user&.id, stock_id: @stock&.id)

      div_change_pct = @stock.div_change_pct
      @subject =
        if div_change_pct.negative?
          "Dividend Cut (#{@stock.symbol})"
        elsif div_change_pct.positive?
          "Dividend Hike (#{@stock.symbol})"
        else
          "Declared Dividend (#{@stock.symbol})"
        end

      mail(to: @user.email, subject: @subject)
    end
  end
end
