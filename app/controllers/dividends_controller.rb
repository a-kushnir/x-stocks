class DividendsController < ApplicationController
  helper :stocks

  def index
    @positions = Position
      .where(user: current_user)
      .where.not(shares: nil)
      .all

    @page_title = 'My Dividends'
    @page_menu_item = :dividends

    respond_to do |format|
      format.html { }
      format.xlsx { generate_xlsx }
    end
  end

  private

  def generate_xlsx
    send_tmp_file('Dividends.xlsx') do |file_name|
      Xlsx::Dividends.new.generate(file_name, @positions)
    end
  end

end
