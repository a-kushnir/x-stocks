# frozen_string_literal: true

# Controller to provide home page information
class HomeController < ApplicationController
  layout 'application_old'

  def index
    @page_title = 'Home'
    @page_menu_item = :home
  end

  def fear_n_greed_image
    image_path = Etl::Refresh::FearNGreed.new.image_path
    send_file(image_path, type: 'image/png', disposition: 'inline')
  end
end
