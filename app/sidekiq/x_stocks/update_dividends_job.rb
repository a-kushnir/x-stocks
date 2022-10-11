# frozen_string_literal: true

module XStocks
  # Demo Job
  class UpdateDividendsJob
    include Sidekiq::Job
    sidekiq_options retry: false

    def perform(stock_symbol = random_stock_symbol)
      stock = XStocks::AR::Stock.find_by(symbol: stock_symbol)
      updated = false

      data_loader = Etl::Extract::DataLoader.new
      token_store ||= Etl::Extract::TokenStore.new(Etl::Extract::Polygon::TOKEN_KEY, nil)
      token_store.try_token do |token|
        json = Etl::Extract::Polygon.new(data_loader, token).dividends(stock)
        updated = Etl::Transform::Polygon.new.dividends(stock, json)
      end

      notify(stock) if updated
    end

    def random_stock_symbol
      XStocks::AR::Stock.pluck(:symbol).sample
    end

    def notify(stock)
      user_ids = XStocks::AR::User.where(dividend_notifications: true).pluck(:id)
      user_ids.each do |user_id|
        XStocks::NotificationMailer.with(user_id: user_id, stock_symbol: stock.symbol).dividend_change.deliver_now
      end
    end
  end
end
