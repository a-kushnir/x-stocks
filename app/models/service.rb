class Service < ApplicationRecord

  def self.fast_update?
    Etl::Refresh::Finnhub.new.hourly_all_stocks?
  end

  def self.slow_update?
    Etl::Refresh::Yahoo.new.daily_all_stocks? ||
    Etl::Refresh::Finnhub.new.daily_all_stocks? ||
    Etl::Refresh::Iexapis.new.weekly_all_stocks? ||
    Etl::Refresh::Dividend.new.weekly_all_stocks?
  end

  def self.lock(key)
    service = Service.find_or_create_by!(key: key)
    if service.locked_at.nil? ||
        service.locked_at < 1.hour.ago

      rows_updated = Service
        .where(id: service.id, locked_at: service.locked_at)
        .update_all(locked_at: DateTime.now)

      if rows_updated == 1
        service.reload
        service.error = nil
        service.instance_variable_set :@log_writer, ''

        begin
          yield service
        rescue Exception => error
          service.error = "Message: #{error.message}\nBacktrace:\n#{Backtrace.clean(error.backtrace).join("\n")}"
        end

        service.log = service.instance_variable_get :@log_writer
        service.last_run_at = DateTime.now
        service.locked_at = nil
        service.save!

        true
      end
    end
  end

  def self.[](key)
    self.select('locked_at, last_run_at').find_or_initialize_by(key: key)
  end

  def locked?
    locked_at && locked_at > 1.hour.ago
  end

  def runnable?(period)
    !locked? && (!last_run_at || last_run_at < period.ago)
  end

  def log_info(text)
    @log_writer ||= ''
    @log_writer << "[#{DateTime.now}] INFO #{text}\n"
  end

  def log_error(error)
    @log_writer ||= ''
    @log_writer << "[#{DateTime.now}] ERROR Message: #{error.message}\nBacktrace:\n#{Backtrace.clean(error.backtrace).join("\n")}"
  end

end
