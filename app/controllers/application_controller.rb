class ApplicationController < ActionController::Base

  private

  def not_found
    @page_title = '404 Page not found'
    respond_to do |format|
      format.html { render :file => "/errors/404", layout: 'application', :status => :not_found }
      format.xml  { head :not_found }
      format.any  { head :not_found }
    end
  end
end
