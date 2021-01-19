# frozen_string_literal: true

module XStocks
  class Service
    # Service Logger Business Model
    class Logger
      attr_reader :log
      attr_accessor :text_size_limit

      def initialize
        @log = ''
        @text_size_limit = 512
      end

      def log_info(text)
        @log += "[#{DateTime.now}] INFO #{limit_text_size(text)}\n"
      end

      def log_error(error)
        @log += "[#{DateTime.now}] ERROR Message: #{error.message}\nBacktrace:\n#{Backtrace.clean(error.backtrace).join("\n")}"
      end

      private

      def limit_text_size(value)
        value = value.to_s
        text_size_limit && value.size > text_size_limit ? "#{value[0..text_size_limit - 1]}..." : value
      end
    end
  end
end
