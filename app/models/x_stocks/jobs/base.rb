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
        {}
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

      protected

      def text_field_tag(placeholder: nil)
        { text: { placeholder: placeholder } }
      end

      def file_field_tag
        { file: true }
      end

      def select_tag(values:, include_blank: nil, selected: nil)
        values = [include_blank] + values unless include_blank.nil?
        { select: { values: values, selected: selected } }
      end

      def stock_values
        XStocks::AR::Stock.order(:symbol).all.map { |s| ["#{s.symbol} - #{s.company_name}", s.id] }
      end

      private

      def base_refresh
        Etl::Refresh::Base.new(nil)
      end
    end
  end
end
