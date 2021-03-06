# frozen_string_literal: true

# Cleans backtrace to make it more readable
class Backtrace
  def self.clean(backtrace)
    bc = ActiveSupport::BacktraceCleaner.new
    bc.add_filter { |line| line.gsub(Rails.root.to_s, '<root>') }
    bc.filter(backtrace)
  end
end
