class HomeController < ApplicationController

  def index
    @page_title = 'Home'
    @page_menu_item = :home
  end

end
