module ServicesHelper

  def service_path(service_runner)
    "/services/#{URI.escape(service_runner.lookup_code)}"
  end

  def service_log_path(service_runner)
    "/services/#{URI.escape(service_runner.lookup_code)}/log"
  end

  def service_error_path(service_runner)
    "/services/#{URI.escape(service_runner.lookup_code)}/error"
  end

end
