# frozen_string_literal: true

class Backtrace
  def self.clean(backtrace)
    bc = ActiveSupport::BacktraceCleaner.new
    bc.add_filter { |line| line.gsub(Rails.root.to_s, '<root>') }
    bc.filter(backtrace)
  end
end
