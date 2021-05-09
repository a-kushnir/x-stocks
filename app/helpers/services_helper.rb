# frozen_string_literal: true

# Helper methods for ServicesController
module ServicesHelper
  def run_service_path(job)
    "/services/#{CGI.escape(job.lookup_code)}/run"
  end

  def service_log_path(job)
    "/services/#{CGI.escape(job.lookup_code)}/log"
  end

  def service_error_path(job)
    "/services/#{CGI.escape(job.lookup_code)}/error"
  end

  def service_file_path(job)
    "/services/#{CGI.escape(job.lookup_code)}/file"
  end
end
