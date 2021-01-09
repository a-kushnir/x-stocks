# frozen_string_literal: true

module Etl
  module Transform
    class Base
      attr_reader :logger

      def initialize(logger)
        @logger = logger
      end

      protected

      def number?(value)
        value =~ /^[\-+]?[0-9]*\.?[0-9]*$/i
      end

      def number_or_nil(value)
        number?(value) ? value.to_d : nil
      end
    end
  end
end
