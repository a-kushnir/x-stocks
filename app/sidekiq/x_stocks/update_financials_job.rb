# frozen_string_literal: true

module XStocks
  # Demo Job
  class UpdateFinancialsJob
    include Sidekiq::Job
    sidekiq_options retry: false

    PAUSE = 60 / 5 # Limit up to 5 request per minute (2 sub-requests per a request)

    def perform(stock_symbol = random_stock_symbol)
      stock = XStocks::AR::Stock.find_by(symbol: stock_symbol)
      financials = receive_updates(stock)

      ActiveRecord::Base.transaction do
        financials.each(&:save!)
        stock.save!
      end
    end

    def receive_updates(stock)
      updates = []

      token_store = Etl::Extract::TokenStore.new(Etl::Extract::Polygon::TOKEN_KEY, nil)
      transform = Etl::Transform::Polygon.new(stock)

      stock = XStocks::Stock.new(stock)

      json = first_page(stock, token_store)
      new_rows, existing_rows = transform.financials(json) { |node| source_filing_file(node, token_store) }
      return updates unless new_rows

      updates.concat(new_rows)

      while existing_rows.none? && (json = next_page(json, token_store))
        new_rows, existing_rows = transform.financials(json) { |node| source_filing_file(node, token_store) }
        return updates unless new_rows

        updates.concat(new_rows)
      end

      updates
    end

    def first_page(stock, token_store)
      token_store.try_token do |token|
        Etl::Extract::Polygon.new(data_loader, token).financials(stock)
      end
    end

    def next_page(json, token_store)
      return if json['next_url'].blank?

      sleep(PAUSE)
      token_store.try_token do |token|
        Etl::Extract::Polygon.new(data_loader, token).next_page(json)
      end
    end

    def source_filing_file(node, token_store)
      sleep(PAUSE)
      token_store.try_token do |token|
        Etl::Extract::Polygon.new(data_loader, token).source_filing_file(node)
      end
    end

    def data_loader
      @data_loader ||= Etl::Extract::DataLoader.new
    end

    def random_stock_symbol
      XStocks::AR::Stock.pluck(:symbol).sample
    end
  end
end
