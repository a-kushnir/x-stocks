# frozen_string_literal: true

module XStocks
  # Service Business Model
  class Service
    FAST_UPDATE_JOBS = [
      XStocks::Jobs::FinnhubPriceAll
    ].freeze
    SLOW_UPDATE_JOBS = [
      XStocks::Jobs::YahooStockAll,
      XStocks::Jobs::FinnhubStockAll,
      XStocks::Jobs::IexapisDividendsAll,
      XStocks::Jobs::DividendStockAll
    ].freeze

    def initialize(service = nil, service_ar_class: XStocks::AR::Service)
      @service = service
      @service_ar_class = service_ar_class
    end

    def fast_update?
      ready?(FAST_UPDATE_JOBS)
    end

    def slow_update?
      ready?(SLOW_UPDATE_JOBS)
    end

    def perform_update(&block)
      if fast_update?
        perform(FAST_UPDATE_JOBS, &block)
      elsif slow_update?
        perform(SLOW_UPDATE_JOBS, &block)
      end
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

    def self.find(lookup_code, service_ar_class: XStocks::AR::Service)
      new(service_ar_class.find_or_initialize_by(key: lookup_code), service_ar_class: service_ar_class)
    end

    def locked?
      service_ar_class.where('locked_at > ?', 10.minutes.ago).exists?
    end

    def runnable?(period)
      !locked_one?(service) && (!service.last_run_at || service.last_run_at < period.ago)
    end

    private

    def ready?(jobs)
      jobs.detect { |job| job.new.ready? }
    end

    def perform(jobs, &block)
      jobs.each { |job| job.new.perform(&block) }
    end

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

    XStocks::ARForwarder.delegate_methods(self, :service, XStocks::AR::Service)
  end
end
