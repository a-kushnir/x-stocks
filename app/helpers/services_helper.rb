module ServicesHelper

  def service_path(service_code)
    "/services/#{URI.escape(service_code)}"
  end

end
