# frozen_string_literal: true

# Controller to provide home page information
class HomeController < ApplicationController
  def index
    @page_title = 'Home'
    @page_menu_item = :home
  end
end
