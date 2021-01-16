# frozen_string_literal: true

module ServicesHelper
  def run_service_path(service_runner)
    "/services/#{CGI.escape(service_runner.lookup_code)}/run"
  end

  def service_log_path(service_runner)
    "/services/#{CGI.escape(service_runner.lookup_code)}/log"
  end

  def service_error_path(service_runner)
    "/services/#{CGI.escape(service_runner.lookup_code)}/error"
  end
end
