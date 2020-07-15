class DividendsController < ApplicationController

  def index
    @positions = positions.all

    @page_title = 'My Dividends'
    @page_menu_item = :dividends
  end

  private

  def positions
    Position.where(user_id: current_user.id)
  end

end
