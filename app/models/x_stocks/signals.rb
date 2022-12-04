# frozen_string_literal: true

require 'x_stocks/signals/base'
Dir['x_stocks/signals/*.rb'].sort.each { |file| require file }

module XStocks
  # Detects Buy/Sell Signals
  module Signals
    def self.all
      XStocks::Signals
        .constants
        .map { |const| XStocks::Signals.const_get(const) }
        .select { |klass| klass < XStocks::Signals::Base }
    end
  end
end
