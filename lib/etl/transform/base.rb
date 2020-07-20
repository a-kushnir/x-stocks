module Etl
  module Transform
    class Base

      attr_reader :logger

      def initialize(logger)
        @logger = logger
      end

      protected

      def is_number?(value)
        value =~ /^[\-+]?[0-9]*\.?[0-9]*$/i
      end

      def number_or_nil(value)
        is_number?(value) ? value.to_d : nil
      end

    end
  end
end
