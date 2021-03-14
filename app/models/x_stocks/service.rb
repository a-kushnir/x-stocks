# frozen_string_literal: true

module XStocks
  # Service Business Model
  class Service
    def initialize(service = nil, service_ar_class: XStocks::AR::Service)
      @service = service
      @service_ar_class = service_ar_class
    end

    def fast_update?
      Etl::Refresh::Finnhub.new.hourly_all_stocks?
    end

    def slow_update?
      Etl::Refresh::Yahoo.new.daily_all_stocks? ||
        Etl::Refresh::Finnhub.new.daily_all_stocks? ||
        Etl::Refresh::Iexapis.new.weekly_all_stocks? ||
        Etl::Refresh::Dividend.new.weekly_all_stocks?
    end

    def lock(key, force: false)
      service = service_ar_class.find_or_create_by!(key: key)
      return if !force && locked_one?(service)
      return unless lock!(service)

      service.reload
      service.error = nil

      logger = XStocks::Service::Logger.new
      begin
        yield logger
      rescue Exception => e
        service.error = "Message: #{e.message}\nBacktrace:\n#{Backtrace.clean(e.backtrace).join("\n")}"
        raise e
      ensure
        service.log = logger.log
        service.file_name = logger.file_name
        service.file_type = logger.file_type
        service.file_content = logger.file_content
        service.last_run_at = DateTime.now
        service.locked_at = nil
        service.save!
      end

      true
    end

    def [](key)
      self.class.new(
        service_ar_class.select('locked_at, last_run_at').find_or_initialize_by(key: key),
        service_ar_class: service_ar_class
      )
    end

    def locked?
      service_ar_class.where('locked_at > ?', 10.minutes.ago).exists?
    end

    def runnable?(period)
      !locked_one?(service) && (!service.last_run_at || service.last_run_at < period.ago)
    end

    private

    def lock!(service)
      rows_updated =
        service_ar_class
        .where(id: service.id, locked_at: service.locked_at)
        .update_all(locked_at: DateTime.now)

      rows_updated == 1
    end

    def locked_one?(service)
      service.locked_at && service.locked_at > 10.minutes.ago
    end

    attr_reader :service, :service_ar_class
  end
end
