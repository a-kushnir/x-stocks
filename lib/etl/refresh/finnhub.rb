# frozen_string_literal: true

module Etl
  module Refresh
    # Extracts and transforms data from finnhub.io
    class Finnhub < Base
      PAUSE_SHORT = 1.0 / 10  # Limit up to 10 requests per second
      PAUSE_LONG = 1.0 / 3    # Limit up to 3 requests per second

      ##########
      # Hourly #

      def hourly_all_stocks
        token_store = Etl::Extract::TokenStore.new(Etl::Extract::Finnhub::TOKEN_KEY, logger)

        each_stock_with_message do |stock, message|
          yield message if block_given?
          hourly_one_stock(stock, token_store: token_store)
          sleep(PAUSE_SHORT)
        end

        yield completed_message if block_given?
      end

      def hourly_one_stock(stock, token_store: nil)
        token_store ||= Etl::Extract::TokenStore.new(Etl::Extract::Finnhub::TOKEN_KEY, logger)

        token_store.try_token do |token|
          json = Etl::Extract::Finnhub.new(loader, token).quote(stock)
          Etl::Transform::Finnhub.new.quote(stock, json) if json
        end
      end

      #########
      # Daily #

      def daily_all_stocks
        token_store = Etl::Extract::TokenStore.new(Etl::Extract::Finnhub::TOKEN_KEY, logger)

        each_stock_with_message do |stock, message|
          yield message if block_given?
          daily_one_stock(stock, token_store: token_store)
          sleep(PAUSE_LONG)
        end

        yield completed_message if block_given?
      end

      def daily_one_stock(stock, token_store: nil, immediate: false)
        token_store ||= Etl::Extract::TokenStore.new(Etl::Extract::Finnhub::TOKEN_KEY, logger)

        token_store.try_token do |token|
          json = Etl::Extract::Finnhub.new(loader, token).recommendation(stock)
          Etl::Transform::Finnhub.new.recommendation(stock, json) if json
          sleep(PAUSE_LONG) unless immediate
        end

        token_store.try_token do |token|
          json = Etl::Extract::Finnhub.new(loader, token).metric(stock)
          Etl::Transform::Finnhub.new.metric(stock, json) if json
        end
      end

      def company_all_stocks
        token_store = Etl::Extract::TokenStore.new(Etl::Extract::Finnhub::TOKEN_KEY, logger)

        each_stock_with_message do |stock, message|
          yield message if block_given?
          token_store.try_token do |token|
            json = Etl::Extract::Finnhub.new(loader, token).company(stock)
            Etl::Transform::Finnhub.new.company(stock, json) if json
          end
          sleep(PAUSE_SHORT)
        end

        yield completed_message if block_given?
      end

      def analyze_one_stock(stock, token_store: nil)
        token_store ||= Etl::Extract::TokenStore.new(Etl::Extract::Finnhub::TOKEN_KEY, logger)

        token_store.try_token do |token|
          now = DateTime.now.beginning_of_hour
          json = Etl::Extract::Finnhub.new(loader, token).candle(stock, now - 30.days, now, 60)

          if json
            init_csv_file("#{stock.symbol}_analysis.csv")
            add_csv_file_row(%w[time event price ma60])
            results = XStocks::Analyze::Candle.new.analyze(json['c'], json['t'])
            results.each do |item|
              add_csv_file_row(item.values_at(:time, :event, :price, :ma60))
            end
          end

          sleep(PAUSE_LONG)
        end
      end

      def tech_indicators(resolution)
        token_store = Etl::Extract::TokenStore.new(Etl::Extract::Finnhub::TOKEN_KEY, logger)

        init_csv_file("#{DateTime.now.strftime('%b-%d-%Hh')}_tech_indicators_#{resolution}.csv")
        add_csv_file_row(%w[symbol buy neutral sell signal adx trending])

        each_stock_with_message do |stock, message|
          yield message if block_given?
          token_store.try_token do |token|
            json = Etl::Extract::Finnhub.new(loader, token).tech_indicator(stock, resolution)

            if json.present?
              row = [
                stock.symbol,
                json.dig('technicalAnalysis', 'count', 'buy'),
                json.dig('technicalAnalysis', 'count', 'neutral'),
                json.dig('technicalAnalysis', 'count', 'sell'),
                json.dig('technicalAnalysis', 'signal'),
                json.dig('trend', 'adx'),
                json.dig('trend', 'trending')
              ]
            end
            add_csv_file_row(row) if row && row.compact.size > 1
          end
          sleep(PAUSE_SHORT)
        end

        yield completed_message if block_given?
      end

      private

      def safe_exec
        yield
      rescue Exception
        nil
      end
    end
  end
end
