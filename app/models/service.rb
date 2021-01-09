# frozen_string_literal: true

class Service < ApplicationRecord
  attr_accessor :text_size_limit

  def self.fast_update?
    Etl::Refresh::Finnhub.new.hourly_all_stocks?
  end

  def self.slow_update?
    Etl::Refresh::Yahoo.new.daily_all_stocks? ||
      Etl::Refresh::Finnhub.new.daily_all_stocks? ||
      Etl::Refresh::Iexapis.new.weekly_all_stocks? ||
      Etl::Refresh::Dividend.new.weekly_all_stocks?
  end

  def self.lock(key, force: false)
    service = Service.find_or_create_by!(key: key)
    return if !force && service.locked?
    return unless service.lock!

    service.reload
    service.error = nil
    service.text_size_limit = 512
    service.instance_variable_set :@log_writer, ''

    begin
      yield service
    rescue Exception => e
      service.error = "Message: #{e.message}\nBacktrace:\n#{Backtrace.clean(e.backtrace).join("\n")}"
      raise e
    ensure
      service.log = service.instance_variable_get :@log_writer
      service.last_run_at = DateTime.now
      service.locked_at = nil
      service.save!
    end

    true
  end

  def lock!
    rows_updated =
      Service
      .where(id: id, locked_at: locked_at)
      .update_all(locked_at: DateTime.now)

    rows_updated == 1
  end

  def self.[](key)
    self.select('locked_at, last_run_at').find_or_initialize_by(key: key)
  end

  def self.locked?
    Service.where('locked_at > ?', 10.minutes.ago).exists?
  end

  def locked?
    locked_at && locked_at > 10.minutes.ago
  end

  def runnable?(period)
    !locked? && (!last_run_at || last_run_at < period.ago)
  end

  def log_info(text)
    @log_writer ||= ''
    @log_writer += "[#{DateTime.now}] INFO #{limit_text_size(text)}\n"
  end

  def log_error(error)
    @log_writer ||= ''
    @log_writer += "[#{DateTime.now}] ERROR Message: #{error.message}\nBacktrace:\n#{Backtrace.clean(error.backtrace).join("\n")}"
  end

  private

  def limit_text_size(value)
    value = value.to_s
    text_size_limit && value.size > text_size_limit ? "#{value[0..text_size_limit - 1]}..." : value
  end
end
