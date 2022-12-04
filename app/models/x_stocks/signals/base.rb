# frozen_string_literal: true

module XStocks
  module Signals
    # Base class for Signal Detectors
    class Base
      def initialize(stock)
        @stock = stock
      end

      protected

      attr_reader :stock

      def intersection(line1_old, line1_new, line2_old, line2_new)
        old_state = line1_old > line2_old ? :buy : :sell
        new_state = line1_new > line2_new ? :buy : :sell
        return nil if old_state == new_state

        new_state
      end

      def create_signal(timestamp, value, price)
        XStocks::AR::Signal.create(
          stock: stock,
          timestamp: Time.at(timestamp).to_datetime,
          detection_method: self.class.name.demodulize,
          value: value,
          price: price
        )
      end
    end
  end
end
