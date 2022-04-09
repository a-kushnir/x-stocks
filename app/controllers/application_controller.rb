# frozen_string_literal: true

# Base Application Controller
class ApplicationController < ActionController::Base
  include Pagy::Backend
  include MemorizeParams

  before_action :authenticate_user!

  etag { current_user&.id }

  rescue_from Exception, with: :internal_error if Rails.env.production?

  def not_found(layout: 'application')
    @page_title = '404 Page Not Found'
    @layout = layout

    respond_to do |format|
      format.html { render template: '/errors/404', layout: layout, status: 404 }
      format.xlsx { render template: '/errors/404', layout: layout, status: 404, formats: [:html], content_type: Mime[:html] }
      format.xml  { head 404 }
      format.any  { head 404 }
    end
  end

  private

  def authenticate_user!(*args)
    raise if !user_signed_in? && !is_a?(DeviseController)

    super(*args)
  rescue StandardError
    redirect_to new_user_session_path(request.get? ? { back_url: request.path } : {})
    false
  end

  def internal_error(error = nil, layout: 'application')
    Honeybadger.notify(error)

    @page_title = '500 Internal Server Error'
    @error = error
    @layout = layout

    respond_to do |format|
      format.html { render template: '/errors/500', layout: layout, status: 500 }
      format.xlsx { render template: '/errors/500', layout: layout, status: 500, formats: [:html], content_type: Mime[:html] }
      format.xml  { head 500 }
      format.any  { head 500 }
    end
  end

  def send_tmp_file(file_name)
    file = Tempfile.new(file_name, binmode: true)
    yield file.path
    send_data file.read, filename: file_name
  ensure
    file.close
    file.unlink
  end
end
