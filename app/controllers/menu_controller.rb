# frozen_string_literal: true

# Top menu controller
class MenuController < ApplicationController
  def index
    @page_title = 'Menu'
    @page_menu_item = :menu
  end
end
