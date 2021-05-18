# frozen_string_literal: true

module XStocks
  module Jobs
    # Base Job
    class Base
      attr_accessor :force_lock

      def lookup_code
        @lookup_code ||= self.class.name.demodulize.underscore
      end

      def name
        raise NoMethodError
      end

      def tags
        []
      end

      def perform
        raise NoMethodError
      end

      def interval
        nil
      end

      def schedule
        nil
      end

      def arguments
        []
      end

      def service
        @service ||= XStocks::Service.find(lookup_code)
      end

      def ready?
        raise "This job isn't scheduled" unless interval

        service.runnable?(interval)
      end

      def lock(&block)
        XStocks::Service.new.lock(lookup_code, force: force_lock, &block)
      end

      extend Forwardable
      def_delegators :base_refresh, :stock_message, :completed_message

      private

      def base_refresh
        Etl::Refresh::Base.new(nil)
      end
    end
  end
end
