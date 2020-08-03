class ApplicationController < ActionController::Base

  before_action :authenticate_user!

  rescue_from Exception, with: :internal_error

  def not_found(layout: 'application')
    @page_title = '404 Page not found'
    @layout = layout

    respond_to do |format|
      format.html { render file: '/errors/404', layout: layout, status: 404 }
      format.xlsx { render file: '/errors/404', layout: layout, status: 404, formats: [:html], content_type: Mime[:html] }
      format.xml  { head 404 }
      format.any  { head 404 }
    end
  end

  private

  def internal_error(error = nil, layout: 'application')
    @page_title = '500 Internal Server Error'
    @error = error
    @layout = layout

    respond_to do |format|
      format.html { render file: '/errors/500', layout: layout, status: 500 }
      format.xlsx { render file: '/errors/500', layout: layout, status: 500, formats: [:html], content_type: Mime[:html] }
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
