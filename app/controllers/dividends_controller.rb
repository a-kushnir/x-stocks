class DividendsController < ApplicationController
  helper :stocks

  def index
    @positions = Position
      .where(user: current_user)
      .where.not(shares: nil)
      .all

    @page_title = 'My Dividends'
    @page_menu_item = :dividends
  end

end
