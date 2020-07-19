class ApplicationController < ActionController::Base

  before_action :authenticate_user!

  rescue_from Exception, with: :internal_error

  def not_found
    @page_title = '404 Page not found'
    respond_to do |format|
      format.html { render :file => "/errors/404", layout: 'application', status: 404 }
      format.xml  { head 404 }
      format.any  { head 404 }
    end
  end

  private

  def internal_error(error = nil)
    @page_title = '500 Internal Server Error'
    @error = error
    respond_to do |format|
      format.html { render :file => "/errors/500", layout: 'application', status: 500 }
      format.xml  { head 500 }
      format.any  { head 500 }
    end
  end

end
