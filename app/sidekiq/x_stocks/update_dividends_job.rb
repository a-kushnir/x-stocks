# frozen_string_literal: true

module XStocks
  # Demo Job
  class UpdateDividendsJob
    include Sidekiq::Job
    sidekiq_options retry: false

    PAUSE = 60 / 5 # Limit up to 5 request per minute

    def perform(stock_symbol = random_stock_symbol)
      stock = XStocks::AR::Stock.find_by(symbol: stock_symbol)
      dividends = receive_updates(stock)

      ActiveRecord::Base.transaction do
        dividends.each(&:save!)
        update(stock) # TODO: Add to save callbacks
        stock.save!
      end

      notify(stock) if dividends.any?
    end

    def receive_updates(stock)
      updates = []

      token_store = Etl::Extract::TokenStore.new(Etl::Extract::Polygon::TOKEN_KEY, nil)
      transform = Etl::Transform::Polygon.new(stock)

      json = first_page(stock, token_store)
      new_rows, existing_rows = transform.dividends(json)
      return [] unless new_rows

      updates.concat(new_rows)

      while existing_rows.none? && (json = next_page(json, token_store))
        new_rows, existing_rows = transform.dividends(json)
        return [] unless new_rows

        updates.concat(new_rows)
      end

      updates
    end

    def first_page(stock, token_store)
      token_store.try_token do |token|
        Etl::Extract::Polygon.new(data_loader, token).dividends(stock)
      end
    end

    def next_page(json, token_store)
      return if json['next_url'].blank?

      sleep(PAUSE)
      token_store.try_token do |token|
        Etl::Extract::Polygon.new(data_loader, token).next_page(json)
      end
    end

    def data_loader
      @data_loader ||= Etl::Extract::DataLoader.new
    end

    def random_stock_symbol
      XStocks::AR::Stock.pluck(:symbol).sample
    end

    def update(stock)
      recent_div = stock.dividends.regular.first
      stock.dividend_frequency_num = recent_div&.frequency
      stock.next_div_ex_date = recent_div&.ex_dividend_date
      stock.next_div_payment_date = recent_div&.pay_date
      stock.dividend_amount = recent_div&.amount
      stock.est_annual_dividend = (stock.dividend_frequency_num * stock.dividend_amount if stock.dividend_frequency_num && stock.dividend_amount)
    end

    def notify(stock)
      user_ids = XStocks::AR::User.where(dividend_notifications: true).pluck(:id)
      user_ids.each do |user_id|
        XStocks::NotificationMailer.with(user_id: user_id, stock_symbol: stock.symbol).dividend_change.deliver_now
      end
    end
  end
end
