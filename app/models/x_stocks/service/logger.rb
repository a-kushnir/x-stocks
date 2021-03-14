# frozen_string_literal: true

module XStocks
  class Service
    # Service Logger Business Model
    class Logger
      attr_reader :log, :file_name, :file_type, :file_content
      attr_accessor :text_size_limit

      def initialize
        @log = ''
        @file_name = nil
        @file_type = nil
        @file_content = nil
        @text_size_limit = 512
      end

      def log_info(text)
        @log += "[#{DateTime.now}] INFO #{limit_text_size(text)}\n"
      end

      def log_error(error)
        @log += "[#{DateTime.now}] ERROR Message: #{error.message}\nBacktrace:\n#{Backtrace.clean(error.backtrace).join("\n")}"
      end

      def init_file(file_name, file_type)
        @file_name = file_name
        @file_type = file_type
        @file_content = ''
      end

      def append_file(file_content)
        @file_content += file_content
      end

      private

      def limit_text_size(value)
        value = value.to_s
        text_size_limit && value.size > text_size_limit ? "#{value[0..text_size_limit - 1]}..." : value
      end
    end
  end
end
