module Etl
  module Transform
    class Base

      attr_reader :logger

      def initialize(logger)
        @logger = logger
      end

    end
  end
end
