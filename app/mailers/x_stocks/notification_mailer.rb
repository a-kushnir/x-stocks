# frozen_string_literal: true

module XStocks
  # Test Mailer
  class NotificationMailer < ApplicationMailer
    helper :application,
           :stocks

    def dividend_change
      user_id, stock_symbol = params.values_at(:user_id, :stock_symbol)

      user = XStocks::AR::User.find_by(id: user_id)
      stock = XStocks::AR::Stock.find_by(symbol: stock_symbol)
      position = XStocks::AR::Position.find_or_initialize_by(user_id: user&.id, stock_id: stock&.id)

      @notification = XStocks::Notifications::DividendChange.new(user, stock, position)

      mail(to: user.email, subject: @notification.subject)
    end

    def signals_detected
      user_id, signal_ids = params.values_at(:user_id, :signal_ids)

      user = XStocks::AR::User.find_by(id: user_id)
      signals = XStocks::AR::Signal.where(id: signal_ids).all.sort_by { |signal| signal.stock.symbol }
      positions = XStocks::AR::Position.where(user_id: user.id).index_by(&:stock_id)

      @notification = Struct.new(:subject, :signals, :positions).new(t('notifications.signals_detected.buy_n_sell_signals'), signals, positions)

      mail(to: user.email, subject: @notification.subject)
    end
  end
end
