class DividendsController < ApplicationController
  helper :stocks

  def index
    @positions = Position
      .where(user: current_user)
      .where.not(shares: nil)
      .all

    @columns = columns

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

  def columns
    div = ::Dividend.new
    month_names = []
    div.months.each_with_index do |month, index|
      month_names << (index == 0 || index == 11 ? month.strftime("%b'%y") : month.strftime('%b'))
    end

    columns = []
    columns << {label: 'Yield', index: 1}
    columns << {label: 'Safety', index: 2}

    index = 2
    month_names.each do |month_name|
      columns << {label: month_name, index: index += 1}
    end
    columns << {label: 'Total', index: index + 1}

    columns
  end
end
